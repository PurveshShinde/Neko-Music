import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart'
    hide Engagement;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/track_model.dart';

// ── Isolate worker for YoutubeExplode ──
// Only plain types (String, int, List, Map, SendPort) can cross Isolate boundaries.
// We encode each request as: [SendPort replyTo, String method, ...args]

Future<void> _ytExplodeIsolateEntry(SendPort mainPort) async {
  final receivePort = ReceivePort();
  mainPort.send(receivePort.sendPort);
  final yt = YoutubeExplode();

  await for (final msg in receivePort) {
    final list = msg as List<dynamic>;
    final replyPort = list[0] as SendPort;
    final method = list[1] as String;
    final args = list.sublist(2);

    try {
      dynamic result;
      switch (method) {
        case 'search':
          final results = await yt.search.search(args[0] as String);
          result = results
              .map((v) => {
                    'id': v.id.value,
                    'title': v.title,
                    'author': v.author,
                    'thumbnail': v.thumbnails.highResUrl,
                    'duration': v.duration?.inSeconds,
                  })
              .toList();
          break;

        case 'manifest':
          final videoId = args[0] as String;
          // Use the most permissive clients — ios client avoids PO token issues
          final manifest = await yt.videos.streamsClient.getManifest(
            videoId,
            ytClients: [
              YoutubeApiClient.ios,
              YoutubeApiClient.androidVr,
              YoutubeApiClient.android,
            ],
          );
          final audioOnly = manifest.audioOnly
              .where((s) => s.bitrate.bitsPerSecond >= 40960)
              .sortByBitrate()
              .reversed
              .toList();

          if (audioOnly.isEmpty) throw Exception('No audio streams found');

          final best = audioOnly.firstWhere(
            (s) => s.container.name == 'mp4' || s.container.name == 'm4a',
            orElse: () => audioOnly.first,
          );
          result = best.url.toString();
          break;

        default:
          throw Exception('Unknown method: $method');
      }
      replyPort.send(['ok', result]);
    } catch (e, st) {
      debugPrint('[YTExplode Isolate error] $e\n$st');
      replyPort.send(['error', e.toString()]);
    }
  }
}

class _IsolatedYoutubeExplode {
  final Isolate _isolate;
  final SendPort _sendPort;
  final ReceivePort _receivePort;

  _IsolatedYoutubeExplode._(this._isolate, this._receivePort, this._sendPort);

  static _IsolatedYoutubeExplode? _instance;

  static Future<_IsolatedYoutubeExplode> get() async {
    if (_instance != null) return _instance!;
    final rp = ReceivePort();
    final isolate = await Isolate.spawn(_ytExplodeIsolateEntry, rp.sendPort);
    final sp = await rp.first as SendPort;
    _instance = _IsolatedYoutubeExplode._(isolate, rp, sp);
    return _instance!;
  }

  Future<T> call<T>(String method, List<dynamic> args) async {
    final rp = ReceivePort();
    // Send as plain List — safe across isolate boundaries
    _sendPort.send([rp.sendPort, method, ...args]);
    final reply = await rp.first as List;
    rp.close();
    if (reply[0] == 'error') throw Exception(reply[1]);
    return reply[1] as T;
  }

  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
    _instance = null;
  }
}

// ── Main Service ──

class YouTubeSearchService {
  /// Search using NewPipe on Android (native Java extractor, no 403s),
  /// falls back to YoutubeExplode Isolate on other platforms.
  Future<List<TrackModel>> searchTracks(String query) async {
    return _searchYTExplode(query);
  }

  Future<List<TrackModel>> _searchNewPipe(String query) async {
    try {
      final results = await NewPipeExtractor.search(
        query,
        contentFilters: [SearchContentFilters.videos],
      );
      return results.whereType<VideoSearchResultItem>().map((item) {
        final id = Uri.parse(item.url).queryParameters['v'] ?? '';
        return TrackModel(
          title: item.name,
          artist: item.uploaderName,
          albumArt: '🎵',
          colorSeed: 0xFF1DB954,
          imageUrl: 'https://img.youtube.com/vi/$id/hqdefault.jpg',
          duration: item.duration > 0
              ? Duration(seconds: item.duration)
                  .toString()
                  .split('.')
                  .first
                  .replaceFirst('0:', '')
              : null,
          videoId: id,
        );
      }).toList();
    } catch (e) {
      debugPrint('[NewPipe search failed, falling back to YT Explode]: $e');
      return _searchYTExplode(query);
    }
  }

  Future<List<TrackModel>> _searchYTExplode(String query) async {
    final isolate = await _IsolatedYoutubeExplode.get();
    final results = await isolate.call<List<dynamic>>('search', [query]);
    return results.map((v) {
      return TrackModel(
        title: v['title'] as String,
        artist: v['author'] as String,
        albumArt: '🎵',
        colorSeed: 0xFF1DB954,
        imageUrl: v['thumbnail'] as String?,
        duration: v['duration'] != null
            ? Duration(seconds: v['duration'] as int)
                .toString()
                .split('.')
                .first
                .replaceFirst('0:', '')
            : null,
        videoId: v['id'] as String,
      );
    }).toList();
  }

  /// Get a direct, playable audio stream URL.
  /// On Android: uses NewPipe (Java-native, no 403s from YouTube)
  /// Fallback: uses YoutubeExplode in a background Isolate.
  Future<String> getAudioStreamUrl(String videoId) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        return await _getStreamFromNewPipe(videoId);
      } catch (e) {
        debugPrint('[NewPipe stream failed, falling back to YT Explode]: $e');
        return await _getStreamFromYTExplodeIsolate(videoId);
      }
    }
    return await _getStreamFromYTExplodeIsolate(videoId);
  }

  Future<String> _getStreamFromNewPipe(String videoId) async {
    final info = await NewPipeExtractor.getVideoInfo(videoId);

    // ── Spotube's exact logic: prefer audio-only, filter for direct HTTP URLs ──
    // We must filter for isUrl=true AND deliveryMethod=progressiveHttp.
    // ALWAYS PREFER m4a (mp4) over webm (opus) because some Android decoders
    // play webm/opus at 2x speed due to sample rate misinterpretation.
    final directAudioStreams = info.audioStreams
        .where((s) =>
            s.isUrl && s.deliveryMethod == DeliveryMethod.progressiveHttp)
        .toList();

    if (directAudioStreams.isNotEmpty) {
      // Sort by m4a preference first, then bitrate
      directAudioStreams.sort((a, b) {
        final aName = a.mediaFormat?.name.toLowerCase() ?? '';
        final bName = b.mediaFormat?.name.toLowerCase() ?? '';
        final aIsM4a = aName.contains('m4a') || aName.contains('mp4');
        final bIsM4a = bName.contains('m4a') || bName.contains('mp4');
        if (aIsM4a && !bIsM4a) return -1;
        if (!aIsM4a && bIsM4a) return 1;
        return b.bitrate.compareTo(a.bitrate);
      });
      
      debugPrint(
          '[NewPipe] Using direct audio stream: ${directAudioStreams.first.mediaFormat?.name} at ${directAudioStreams.first.bitrate} bps');
      return directAudioStreams.first.content;
    }

    // Spotube fallback: try muxed videoStreams containing audio
    final directVideoStreams = info.videoStreams
        .where((s) =>
            s.isUrl &&
            s.deliveryMethod == DeliveryMethod.progressiveHttp &&
            !s.isVideoOnly)
        .toList();

    if (directVideoStreams.isNotEmpty) {
      directVideoStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      debugPrint(
          '[NewPipe] Falling back to muxed video stream: ${directVideoStreams.first.content.substring(0, 60)}...');
      return directVideoStreams.first.content;
    }

    // Last resort: any audio stream with a URL (libmpv can handle DASH manifests)
    final anyAudio = info.audioStreams.where((s) => s.isUrl).toList();
    if (anyAudio.isNotEmpty) {
      anyAudio.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      debugPrint('[NewPipe] Using any-isUrl audio stream (may be DASH)');
      return anyAudio.first.content;
    }

    throw Exception('NewPipe: no usable audio streams for $videoId');
  }

  Future<String> _getStreamFromYTExplodeIsolate(String videoId) async {
    debugPrint('[YTExplode Isolate] Fetching manifest for $videoId...');
    final isolate = await _IsolatedYoutubeExplode.get();
    final url = await isolate.call<String>('manifest', [videoId]);
    debugPrint('[YTExplode Isolate] Got URL: ${url.substring(0, 60)}...');
    return url;
  }

  void dispose() {
    _IsolatedYoutubeExplode._instance?.dispose();
  }
}
