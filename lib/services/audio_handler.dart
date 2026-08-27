import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import '../models/track_model.dart';
import 'dart:async';

import '../state/app_state.dart';

class NekoAudioHandler extends BaseAudioHandler with SeekHandler {
  final AppState _appState;
  final Player _player;
  
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playerPositionSubscription;
  StreamSubscription? _playerDurationSubscription;
  StreamSubscription? _playerBufferingSubscription;

  NekoAudioHandler(this._appState) : _player = _appState.playbackController.player {
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _playerStateSubscription = _player.stream.playing.listen((playing) {
      playbackState.add(playbackState.value.copyWith(
        playing: playing,
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: _player.state.buffering ? AudioProcessingState.buffering : AudioProcessingState.ready,
      ));
    });

    _playerPositionSubscription = _player.stream.position.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    _playerBufferingSubscription = _player.stream.buffering.listen((isBuffering) {
      playbackState.add(playbackState.value.copyWith(
        processingState: isBuffering ? AudioProcessingState.buffering : AudioProcessingState.ready,
      ));
    });
  }

  void syncMediaItem(TrackModel track) {
    final newItem = MediaItem(
      id: track.videoId ?? track.spotifyId ?? 'unknown',
      title: track.title,
      artist: track.artist,
      album: track.albumArt,
      duration: track.duration != null ? _parseDuration(track.duration!) : null,
      artUri: track.imageUrl != null ? Uri.parse(track.imageUrl!) : null,
    );
    mediaItem.add(newItem);
    
    // Explicitly broadcast state so the OS media player registers the new item
    playbackState.add(playbackState.value.copyWith(
      playing: _player.state.playing,
      controls: [
        MediaControl.skipToPrevious,
        if (_player.state.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: _player.state.buffering ? AudioProcessingState.buffering : AudioProcessingState.ready,
    ));
  }

  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      return Duration(minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
    } else if (parts.length == 3) {
      return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]), seconds: int.parse(parts[2]));
    }
    return Duration.zero;
  }

  @override
  Future<void> play() => _appState.playbackController.play();

  @override
  Future<void> pause() => _appState.playbackController.pause();

  @override
  Future<void> seek(Duration position) => _appState.playbackController.seek(position);

  @override
  Future<void> skipToNext() async {
    _appState.playNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _appState.playPrevious();
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    _playerDurationSubscription?.cancel();
    _playerBufferingSubscription?.cancel();
  }
}
