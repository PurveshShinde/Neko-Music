import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import '../models/track_model.dart';
import '../services/playback_controller.dart';
import '../services/plugin_manager_service.dart';
import '../services/local_library_service.dart';
import '../services/spotify_metadata_service.dart';
import '../services/audio_handler.dart';
import '../services/download_service.dart';
import '../services/youtube_search_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Lightweight inherited-widget state management for the app.
///
/// Holds global reactive values:
/// - [isGlassmorphismEnabled] — toggles the mini-player visual style.
/// - [currentNavIndex]        — drives bottom navigation.
/// - [currentTrackIndex]      — which mock track is "playing".
/// - [isPlaying]              — play / pause state.
/// - [selectedMoodIndex]      — active mood/genre chip.
class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;
  NekoAudioHandler? audioHandler;
  late final PluginManagerService pluginManager;
  late final LocalLibraryService localLibrary;
  late final SpotifyMetadataService spotifyService;
  late final DownloadService downloadService;
  
  AppState(this._prefs) {
    _isAmoledThemeEnabled = _prefs.getBool('isAmoledThemeEnabled') ?? true;
    _isGlassmorphismEnabled = _prefs.getBool('isGlassmorphismEnabled') ?? false;
    _isFloatingNavigationBarEnabled = _prefs.getBool('isFloatingNavigationBarEnabled') ?? true;
    _isGlassPlayerEnabled = _prefs.getBool('isGlassPlayerEnabled') ?? true;
    _isGlassMiniPlayerEnabled = _prefs.getBool('isGlassMiniPlayerEnabled') ?? true;
    _isGlassNavigationBarEnabled = _prefs.getBool('isGlassNavigationBarEnabled') ?? true;
    _isChromaticAberrationEnabled = _prefs.getBool('isChromaticAberrationEnabled') ?? true;
    _isDepthEffectEnabled = _prefs.getBool('isDepthEffectEnabled') ?? true;
    _isAmoledThemeEnabled = _prefs.getBool('isAmoledThemeEnabled') ?? false;
    _useSpotifyRecommendations = _prefs.getBool('useSpotifyRecommendations') ?? false;

    pluginManager = PluginManagerService();
    localLibrary = LocalLibraryService(_prefs);
    spotifyService = SpotifyMetadataService(pluginManager);
    downloadService = DownloadService(YouTubeSearchService());
    _loadRecentTracks();
    
    pluginManager.bootstrapPlugins().then((_) {
      if (pluginManager.installedPlugins.isNotEmpty) {
        notifyListeners();
      }
    });



    playbackController.onTrackFinished = () {
      playNext();
    };
    
    // Ensure default playlists exist
    localLibrary.ensureLikedSongsPlaylistExists().then((_) =>
      localLibrary.ensureDownloadedSongsPlaylistExists()
    );
  }
  
  void notifyPluginLoaded() {
    notifyListeners();
  }
  
  // ── AMOLED Theme ──
  bool _isAmoledThemeEnabled = false;
  bool get isAmoledThemeEnabled => _isAmoledThemeEnabled;
  set isAmoledThemeEnabled(bool v) {
    if (_isAmoledThemeEnabled != v) {
      _isAmoledThemeEnabled = v;
      _prefs.setBool('isAmoledThemeEnabled', v);
      notifyListeners();
    }
  }

  // ── Glassmorphism toggles ──
  bool _isGlassmorphismEnabled = false; // Master switch
  bool get isGlassmorphismEnabled => _isGlassmorphismEnabled;
  set isGlassmorphismEnabled(bool v) {
    if (_isGlassmorphismEnabled != v) {
      _isGlassmorphismEnabled = v;
      _prefs.setBool('isGlassmorphismEnabled', v);
      notifyListeners();
    }
  }

  bool _isFloatingNavigationBarEnabled = true;
  bool get isFloatingNavigationBarEnabled => _isFloatingNavigationBarEnabled;
  set isFloatingNavigationBarEnabled(bool v) {
    if (_isFloatingNavigationBarEnabled != v) {
      _isFloatingNavigationBarEnabled = v;
      _prefs.setBool('isFloatingNavigationBarEnabled', v);
      notifyListeners();
    }
  }

  bool _isGlassPlayerEnabled = true;
  bool get isGlassPlayerEnabled => _isGlassPlayerEnabled;
  set isGlassPlayerEnabled(bool v) {
    if (_isGlassPlayerEnabled != v) {
      _isGlassPlayerEnabled = v;
      _prefs.setBool('isGlassPlayerEnabled', v);
      notifyListeners();
    }
  }

  bool _isGlassMiniPlayerEnabled = true;
  bool get isGlassMiniPlayerEnabled => _isGlassMiniPlayerEnabled;
  set isGlassMiniPlayerEnabled(bool v) {
    if (_isGlassMiniPlayerEnabled != v) {
      _isGlassMiniPlayerEnabled = v;
      _prefs.setBool('isGlassMiniPlayerEnabled', v);
      notifyListeners();
    }
  }

  bool _isGlassNavigationBarEnabled = true;
  bool get isGlassNavigationBarEnabled => _isGlassNavigationBarEnabled;
  set isGlassNavigationBarEnabled(bool v) {
    if (_isGlassNavigationBarEnabled != v) {
      _isGlassNavigationBarEnabled = v;
      _prefs.setBool('isGlassNavigationBarEnabled', v);
      notifyListeners();
    }
  }

  bool _isChromaticAberrationEnabled = true;
  bool get isChromaticAberrationEnabled => _isChromaticAberrationEnabled;
  set isChromaticAberrationEnabled(bool v) {
    if (_isChromaticAberrationEnabled != v) {
      _isChromaticAberrationEnabled = v;
      _prefs.setBool('isChromaticAberrationEnabled', v);
      notifyListeners();
    }
  }

  bool _isDepthEffectEnabled = true;
  bool get isDepthEffectEnabled => _isDepthEffectEnabled;
  set isDepthEffectEnabled(bool v) {
    if (_isDepthEffectEnabled != v) {
      _isDepthEffectEnabled = v;
      _prefs.setBool('isDepthEffectEnabled', v);
      notifyListeners();
    }
  }

  // ── Content ──
  bool _useSpotifyRecommendations = false;
  bool get useSpotifyRecommendations => _useSpotifyRecommendations;
  set useSpotifyRecommendations(bool v) {
    if (_useSpotifyRecommendations != v) {
      _useSpotifyRecommendations = v;
      _prefs.setBool('useSpotifyRecommendations', v);
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

  // ── Listening History ──
  List<TrackModel> _recentlyListened = [];
  List<TrackModel> get recentlyListened => _recentlyListened;

  void _loadRecentTracks() {
    try {
      final jsonList = _prefs.getStringList('recently_listened') ?? [];
      _recentlyListened = jsonList.map((j) => TrackModel.fromJson(json.decode(j))).toList();
    } catch (e) {
      _recentlyListened = [];
    }
  }

  void _addRecentTrack(TrackModel track) {
    // Avoid consecutive duplicates
    if (_recentlyListened.isNotEmpty && _recentlyListened.first.videoId == track.videoId) return;

    // Remove if exists to move to top
    _recentlyListened.removeWhere((t) => t.videoId == track.videoId);
    _recentlyListened.insert(0, track);
    
    // Cap at 20 tracks
    if (_recentlyListened.length > 20) {
      _recentlyListened = _recentlyListened.sublist(0, 20);
    }
    
    final jsonList = _recentlyListened.map((t) => json.encode(t.toJson())).toList();
    _prefs.setStringList('recently_listened', jsonList);
  }



  Future<void> playTrack(TrackModel track) async {
    _queue = [track];
    _queueIndex = 0;
    notifyListeners();
    
    // Start playback
    final playFuture = playbackController.playTrack(track);
    audioHandler?.syncMediaItem(track);
    _addRecentTrack(track);
    
    // In the background, fetch similar tracks to create an autoplay "Radio" queue
    spotifyService.getSimilarTracks(track).then((recommendations) {
      // Only append if the queue is still just this single song
      if (recommendations.isNotEmpty && _queue.length == 1 && _queue[0].title == track.title) {
        _queue.addAll(recommendations);
        notifyListeners();
      }
    });
    
    await playFuture;
  }

  Future<void> playQueue(List<TrackModel> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _queueIndex = startIndex.clamp(0, tracks.length - 1);
    notifyListeners();
    final track = _queue[_queueIndex];
    audioHandler?.syncMediaItem(track);
    _addRecentTrack(track);
    await playbackController.playTrack(track);
  }

  Future<void> playNext() async {
    if (_queue.isEmpty) return;
    if (_queueIndex < _queue.length - 1) {
      _queueIndex++;
      notifyListeners();
      final track = _queue[_queueIndex];
      audioHandler?.syncMediaItem(track);
      _addRecentTrack(track);
      await playbackController.playTrack(track);
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
          final track = _queue[_queueIndex];
          audioHandler?.syncMediaItem(track);
          _addRecentTrack(track);
          await playbackController.playTrack(track);
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
      final track = _queue[_queueIndex];
      audioHandler?.syncMediaItem(track);
      await playbackController.playTrack(track);
    }
  }

  void togglePlayPause() {
    if (playbackController.isPlaying) {
      playbackController.pause();
    } else {
      playbackController.play();
    }
    notifyListeners();
    if (currentTrack != null) {
      audioHandler?.syncMediaItem(currentTrack!);
    }
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
      _selectedMoodIndex = v;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    playbackController.dispose();
    super.dispose();
  }
}

/// InheritedWidget + StatefulWidget wrapper so descendants can access [AppState].
class AppStateProvider extends StatefulWidget {
  final SharedPreferences prefs;
  const AppStateProvider({super.key, required this.child, required this.prefs});
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
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(widget.prefs);
    _initAudioService();
    _requestPermissions();
    _state.addListener(_onChanged);
    _state.pluginManager.bootstrapPlugins().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('firstTimePluginsInstalled') != true) {
        try {
          await _state.pluginManager.installFromUrl('https://github.com/KRTirtho/spotube-plugin-youtube-audio');
          await _state.pluginManager.installFromUrl('https://github.com/sonic-liberation/spotube-plugin-spotify');
          await prefs.setBool('firstTimePluginsInstalled', true);
        } catch (e) {
          debugPrint('Error pre-installing plugins: $e');
        }
      }
      _state.notifyPluginLoaded();
    });
  }

  Future<void> _requestPermissions() async {
    // Request notification and storage permissions on startup
    await [
      Permission.notification,
      Permission.storage,
      Permission.audio,
    ].request();
  }

  Future<void> _initAudioService() async {
    _state.audioHandler = await AudioService.init(
      builder: () => NekoAudioHandler(_state),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.neko.neko.channel.audio',
        androidNotificationChannelName: 'Neko Audio Playback',
        androidNotificationOngoing: true,
      ),
    );
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
