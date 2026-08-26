import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';
import '../models/track_model.dart';
import 'youtube_search_service.dart';

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    required this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration total;
}

class PlaybackController {
  final Player _player = Player();
  final YouTubeSearchService _ytService = YouTubeSearchService();

  VoidCallback? onTrackFinished;

  PlaybackController() {
    // Log any player errors for debugging
    _player.stream.error.listen((err) {
      debugPrint('[media_kit player error]: $err');
    });

    _player.stream.completed.listen((completed) {
      if (completed && onTrackFinished != null) {
        onTrackFinished!();
      }
    });
  }

  // ── Streams for the UI ──
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration?> get durationStream =>
      _player.stream.duration.map((d) => d == Duration.zero ? null : d);
  Stream<bool> get bufferingStream => _player.stream.buffering;

  Stream<DurationState> get durationStateStream => Rx.combineLatest3<Duration, Duration, Duration, DurationState>(
        _player.stream.position,
        _player.stream.buffer,
        _player.stream.duration,
        (position, buffer, duration) => DurationState(
          progress: position,
          buffered: buffer,
          total: duration,
        ),
      );

  bool get isPlaying => _player.state.playing;
  Duration get position => _player.state.position;
  Duration? get duration {
    final d = _player.state.duration;
    return d == Duration.zero ? null : d;
  }

  Future<void> playTrack(TrackModel track) async {
    String? videoId = track.videoId;
    if (videoId == null) {
      // Resolve videoId using YouTubeSearchService (Spotube BYOMM pattern)
      debugPrint('[PlaybackController] No videoId for "${track.title}", resolving via YouTube...');
      final results = await _ytService.searchTracks('${track.title} ${track.artist} audio');
      if (results.isNotEmpty) {
        videoId = results.first.videoId;
        track.videoId = videoId; // cache it for future playbacks
      }
      
      if (videoId == null) {
        throw Exception('Could not resolve audio stream for track: ${track.title}');
      }
    }

    try {
      // Extract the stream URL (NewPipe on Android, YT Explode Isolate otherwise)
      final streamUrl = await _ytService.getAudioStreamUrl(videoId);

      // Build the Media object with custom headers passed directly to libmpv.
      // libmpv uses these headers for ALL requests (initial, range, redirects)
      // so YouTube's CDN sees a proper browser fingerprint and never returns 403.
      final media = Media(
        streamUrl,
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Referer': 'https://www.youtube.com/',
          'Origin': 'https://www.youtube.com',
        },
      );

      await _player.open(media, play: true);
    } catch (e) {
      throw Exception('Failed to play track: $e');
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);

  void dispose() {
    _player.dispose();
    _ytService.dispose();
  }
}
