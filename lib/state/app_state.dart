import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../services/playback_controller.dart';
import '../services/plugin_manager_service.dart';
import '../services/spotify_metadata_service.dart';

/// Lightweight inherited-widget state management for the app.
///
/// Holds global reactive values:
/// - [isGlassmorphismEnabled] — toggles the mini-player visual style.
/// - [currentNavIndex]        — drives bottom navigation.
/// - [currentTrackIndex]      — which mock track is "playing".
/// - [isPlaying]              — play / pause state.
/// - [selectedMoodIndex]      — active mood/genre chip.
class AppState extends ChangeNotifier {
  final PluginManagerService pluginManager = PluginManagerService();
  
  void notifyPluginLoaded() {
    notifyListeners();
  }
  // ── Glassmorphism toggles ──
  bool _isGlassmorphismEnabled = false; // Master switch
  bool get isGlassmorphismEnabled => _isGlassmorphismEnabled;
  set isGlassmorphismEnabled(bool v) {
    if (_isGlassmorphismEnabled != v) {
      _isGlassmorphismEnabled = v;
      notifyListeners();
    }
  }

  bool _isFloatingNavigationBarEnabled = true;
  bool get isFloatingNavigationBarEnabled => _isFloatingNavigationBarEnabled;
  set isFloatingNavigationBarEnabled(bool v) {
    if (_isFloatingNavigationBarEnabled != v) {
      _isFloatingNavigationBarEnabled = v;
      notifyListeners();
    }
  }

  bool _isGlassPlayerEnabled = true;
  bool get isGlassPlayerEnabled => _isGlassPlayerEnabled;
  set isGlassPlayerEnabled(bool v) {
    if (_isGlassPlayerEnabled != v) {
      _isGlassPlayerEnabled = v;
      notifyListeners();
    }
  }

  bool _isGlassMiniPlayerEnabled = true;
  bool get isGlassMiniPlayerEnabled => _isGlassMiniPlayerEnabled;
  set isGlassMiniPlayerEnabled(bool v) {
    if (_isGlassMiniPlayerEnabled != v) {
      _isGlassMiniPlayerEnabled = v;
      notifyListeners();
    }
  }

  bool _isGlassNavigationBarEnabled = true;
  bool get isGlassNavigationBarEnabled => _isGlassNavigationBarEnabled;
  set isGlassNavigationBarEnabled(bool v) {
    if (_isGlassNavigationBarEnabled != v) {
      _isGlassNavigationBarEnabled = v;
      notifyListeners();
    }
  }

  bool _isChromaticAberrationEnabled = true;
  bool get isChromaticAberrationEnabled => _isChromaticAberrationEnabled;
  set isChromaticAberrationEnabled(bool v) {
    if (_isChromaticAberrationEnabled != v) {
      _isChromaticAberrationEnabled = v;
      notifyListeners();
    }
  }

  bool _isDepthEffectEnabled = true;
  bool get isDepthEffectEnabled => _isDepthEffectEnabled;
  set isDepthEffectEnabled(bool v) {
    if (_isDepthEffectEnabled != v) {
      _isDepthEffectEnabled = v;
      notifyListeners();
    }
  }

  // ── Bottom nav ──
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;
  set currentNavIndex(int v) {
    if (_currentNavIndex != v) {
      _currentNavIndex = v;
      notifyListeners();
    }
  }



  // ── Playback State ──
  final PlaybackController playbackController = PlaybackController();
  
  List<TrackModel> _queue = [];
  int _queueIndex = -1;

  TrackModel? get currentTrack {
    if (_queueIndex >= 0 && _queueIndex < _queue.length) {
      return _queue[_queueIndex];
    }
    return null;
  }

  AppState() {
    playbackController.onTrackFinished = () {
      playNext();
    };
  }

  Future<void> playTrack(TrackModel track) async {
    _queue = [track];
    _queueIndex = 0;
    notifyListeners();
    await playbackController.playTrack(track);
  }

  Future<void> playQueue(List<TrackModel> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _queueIndex = startIndex.clamp(0, tracks.length - 1);
    notifyListeners();
    await playbackController.playTrack(_queue[_queueIndex]);
  }

  Future<void> playNext() async {
    if (_queue.isEmpty) return;
    if (_queueIndex < _queue.length - 1) {
      _queueIndex++;
      notifyListeners();
      await playbackController.playTrack(_queue[_queueIndex]);
    } else {
      // Reached the end of the queue. Implement recommendation core.
      try {
        final current = _queue[_queueIndex];
        final spotifyService = SpotifyMetadataService(pluginManager);
        final similar = await spotifyService.getSimilarTracks(current);
        if (similar.isNotEmpty) {
          _queue.addAll(similar);
          _queueIndex++;
          notifyListeners();
          await playbackController.playTrack(_queue[_queueIndex]);
        }
      } catch (e) {
        debugPrint('Failed to fetch recommended tracks: $e');
      }
    }
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;
    if (playbackController.position.inSeconds > 3) {
      // If playing for more than 3 seconds, restart current track
      await playbackController.seek(Duration.zero);
    } else if (_queueIndex > 0) {
      _queueIndex--;
      notifyListeners();
      await playbackController.playTrack(_queue[_queueIndex]);
    }
  }

  void togglePlayPause() {
    if (playbackController.isPlaying) {
      playbackController.pause();
    } else {
      playbackController.play();
    }
    notifyListeners();
  }

  void skipNext(int totalTracks) {
    playNext();
  }

  void skipPrevious(int totalTracks) {
    playPrevious();
  }

  // ── Selected mood chip ──
  int _selectedMoodIndex = 0;
  int get selectedMoodIndex => _selectedMoodIndex;
  set selectedMoodIndex(int v) {
    if (_selectedMoodIndex != v) {
      _selectedMoodIndex = v;
      notifyListeners();
    }
  }
}

/// InheritedWidget + StatefulWidget wrapper so descendants can access [AppState].
class AppStateProvider extends StatefulWidget {
  const AppStateProvider({super.key, required this.child});
  final Widget child;

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAppState>()!
        .state;
  }

  @override
  State<AppStateProvider> createState() => _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onChanged);
    _state.pluginManager.bootstrapPlugins().then((_) {
      _state.notifyPluginLoaded();
    });
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _state.removeListener(_onChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAppState(state: _state, child: widget.child);
  }
}

class _InheritedAppState extends InheritedWidget {
  const _InheritedAppState({
    required this.state,
    required super.child,
  });
  final AppState state;

  @override
  bool updateShouldNotify(_InheritedAppState old) => true;
}
