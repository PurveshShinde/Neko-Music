import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart'
    hide Engagement;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/track_model.dart';
import '../models/playlist_model.dart';

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

        case 'related':
          final video = await yt.videos.get(args[0] as String);
          final relatedList = await yt.videos.getRelatedVideos(video);
          if (relatedList == null) {
            result = <Map<String, dynamic>>[];
            break;
          }
          result = relatedList
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
    return _searchNewPipe(query);
  }

  Future<List<dynamic>> searchCategorized(String query, String category) async {
    try {
      SearchContentFilters filter;
      String backendQuery = query;

      switch (category.toLowerCase()) {
        case 'songs':
          filter = SearchContentFilters.videos;
          backendQuery = '$query official audio';
          break;
        case 'albums':
          filter = SearchContentFilters.playlists;
          backendQuery = '$query album';
          break;
        case 'playlists':
          filter = SearchContentFilters.playlists;
          break;
        case 'all':
        default:
          filter = SearchContentFilters.all;
          break;
      }

      final results = await NewPipeExtractor.search(
        backendQuery,
        contentFilters: [filter],
      );

      final List<dynamic> parsedResults = [];

      for (var item in results) {
        if (item is VideoSearchResultItem) {
          final id = Uri.parse(item.url).queryParameters['v'] ?? '';
          
          final track = TrackModel(
            title: item.name,
            artist: item.uploaderName,
            albumArt: '🎵',
            colorSeed: 0xFF1DB954,
            imageUrl: 'https://img.youtube.com/vi/$id/hqdefault.jpg',
            duration: item.duration > 0
                ? Duration(seconds: item.duration).toString().split('.').first.replaceFirst('0:', '')
                : null,
            videoId: id,
          );
          
          parsedResults.add(track);
        } else if (item is PlaylistSearchResultItem) {
          final id = Uri.parse(item.url).queryParameters['list'] ?? '';
          if (id.isEmpty) continue;
          
          final playlist = PlaylistModel(
            title: item.name,
            subtitle: (filter == SearchContentFilters.musicAlbums || item.playlistType.toString().contains('ALBUM'))
                ? 'Album • ${item.uploaderName}'
                : 'Playlist • ${item.uploaderName}',
            imageUrl: item.thumbnails.isNotEmpty ? item.thumbnails.first.url : null,
            colorSeed: 0xFF1DB954,
            query: id, // Use query field to store YT Playlist ID
            isAlbum: filter == SearchContentFilters.musicAlbums,
          );
          
          parsedResults.add(playlist);
        }
      }

      // If category is Songs, run aggressive deduplication
      if (category.toLowerCase() == 'songs') {
        return _deduplicateTracks(parsedResults.whereType<TrackModel>().toList());
      }

      return parsedResults;
    } catch (e) {
      debugPrint('[Categorized search failed]: $e');
      return [];
    }
  }

  List<TrackModel> _deduplicateTracks(List<TrackModel> rawTracks) {
    final seenTitles = <String>[];
    final uniqueTracks = <TrackModel>[];

    for (var track in rawTracks) {
      if (track.duration != null) {
        final parts = track.duration!.split(':');
        int totalSeconds = 0;
        if (parts.length == 2) {
          totalSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        } else if (parts.length == 3) {
          totalSeconds = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
        }

        // Only apply strict duration filtering if a duration exists
        if (totalSeconds > 0 && (totalSeconds < 60 || totalSeconds > 900)) continue;
      }

      // Normalize title aggressively
      String coreTitle = track.title.toLowerCase().split(RegExp(r'[-|,|\|]')).first.trim();
      coreTitle = coreTitle
          .replaceAll(RegExp(r'\(.*?\)'), '')
          .replaceAll(RegExp(r'\[.*?\]'), '')
          .replaceAll(RegExp(r'\b(official|video|lyric|lyrics|audio|full|song|track|music)\b'), '')
          .replaceAll(RegExp(r'[^a-z0-9]'), '')
          .trim();
          
      if (coreTitle.isEmpty) {
        coreTitle = track.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      }

      bool isDuplicate = false;
      for (var existing in seenTitles) {
        if (existing.isNotEmpty && coreTitle.isNotEmpty) {
          if (existing.contains(coreTitle) || coreTitle.contains(existing)) {
            isDuplicate = true;
            break;
          }
        }
      }

      if (!isDuplicate) {
        seenTitles.add(coreTitle);
        uniqueTracks.add(track);
      }
    }
    
    return uniqueTracks;
  }

  Future<List<TrackModel>> _searchNewPipe(String query) async {
    try {
      // 1. Smart Search Modifier
      final backendQuery = '$query official audio';
      final results = await NewPipeExtractor.search(
        backendQuery,
        contentFilters: [SearchContentFilters.videos],
      );

      final rawTracks = results.whereType<VideoSearchResultItem>().map((item) {
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

      // 2. Strict Duration Filtering & 3. Deduplication
      final seenTitles = <String>[];
      final uniqueTracks = <TrackModel>[];

      for (var track in rawTracks) {
        if (track.duration == null) continue;
        
        final parts = track.duration!.split(':');
        int totalSeconds = 0;
        if (parts.length == 2) {
          totalSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        } else if (parts.length == 3) {
          totalSeconds = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
        }

        // Filter: > 1:30 and < 10:00
        if (totalSeconds < 90 || totalSeconds > 600) continue;

        // Normalize title aggressively
        String coreTitle = track.title.toLowerCase().split(RegExp(r'[-|,|\|]')).first.trim();
        coreTitle = coreTitle
            .replaceAll(RegExp(r'\(.*?\)'), '')
            .replaceAll(RegExp(r'\[.*?\]'), '')
            .replaceAll(RegExp(r'\b(official|video|lyric|lyrics|audio|full|song|track|music)\b'), '')
            .replaceAll(RegExp(r'[^a-z0-9]'), '')
            .trim();
            
        if (coreTitle.isEmpty) {
          coreTitle = track.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        }

        bool isDuplicate = false;
        for (var existing in seenTitles) {
          if (existing.isNotEmpty && coreTitle.isNotEmpty) {
            if (existing.contains(coreTitle) || coreTitle.contains(existing)) {
              isDuplicate = true;
              break;
            }
          }
        }

        if (!isDuplicate) {
          seenTitles.add(coreTitle);
          uniqueTracks.add(track);
        }
      }

      return uniqueTracks;
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

  Future<List<TrackModel>> getRelatedTracks(String videoId) async {
    try {
      final isolate = await _IsolatedYoutubeExplode.get();
      final results = await isolate.call<List<dynamic>>('related', [videoId]);
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
    } catch (e) {
      debugPrint('[YTExplode getRelatedTracks failed]: $e');
      return [];
    }
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
