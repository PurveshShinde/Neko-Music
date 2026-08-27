import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/track_model.dart';
import '../models/playlist_model.dart';
import 'youtube_search_service.dart';
import 'local_library_service.dart';

enum DownloadState { none, pending, downloading, completed, failed }

class DownloadTask {
  final TrackModel track;
  final ValueNotifier<DownloadState> state;
  final ValueNotifier<double> progress;

  DownloadTask({required this.track})
      : state = ValueNotifier(DownloadState.pending),
        progress = ValueNotifier(0.0);
}

class DownloadService {
  final YouTubeSearchService _searchService;
  final http.Client _client = http.Client();
  final Map<String, DownloadTask> _activeDownloads = {};
  
  // Singleton instance
  static DownloadService? _instance;
  
  factory DownloadService(YouTubeSearchService searchService) {
    _instance ??= DownloadService._internal(searchService);
    return _instance!;
  }
  
  DownloadService._internal(this._searchService);

  // Allow UI to listen to changes in active downloads map
  final ValueNotifier<int> downloadEvent = ValueNotifier(0);

  DownloadTask? getTask(String trackId) => _activeDownloads[trackId];
  
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Just try to request, but don't strictly block if they say no, 
      // because we might be writing to Android/data which doesn't need it!
      if (await Permission.storage.isGranted) return true;
      await Permission.storage.request();
      
      // On Android 13+, storage is denied, so we request audio
      await Permission.audio.request();
      
      return true; // Always return true and let FileSystemException catch if it fails
    }
    return true;
  }

  Future<String> _getDownloadDirectory(String? playlistName) async {
    final prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('downloadPath');
    
    if (path == null || path == 'Default (App Data)') {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        path = dir?.path;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      }
    }
    
    if (path == null) throw Exception("Could not find download directory");

    if (playlistName != null) {
      final sanitizedName = playlistName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      path = '$path/$sanitizedName';
    }

    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> downloadTrack(TrackModel track, {String? playlistName}) async {
    // If already downloaded or in progress, skip
    if (_activeDownloads.containsKey(track.id)) {
      final currentState = _activeDownloads[track.id]!.state.value;
      if (currentState == DownloadState.downloading || currentState == DownloadState.completed) {
        return; 
      }
    }

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      debugPrint('Storage permission denied');
      return;
    }

    final task = DownloadTask(track: track);
    _activeDownloads[track.id] = task;
    task.state.value = DownloadState.downloading;
    downloadEvent.value++; // trigger UI update

    try {
      String? videoId = track.videoId;
      if (videoId == null) {
        final results = await _searchService.searchTracks('${track.title} ${track.artist} audio');
        if (results.isNotEmpty) {
          videoId = results.first.videoId;
        }
      }

      if (videoId == null) throw Exception('No video ID resolved');

      final String streamUrl = await _searchService.getAudioStreamUrl(videoId);

      final dirPath = await _getDownloadDirectory(playlistName);
      String sanitizedTitle = '${track.title} - ${track.artist}'.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      if (sanitizedTitle.length > 80) {
        sanitizedTitle = sanitizedTitle.substring(0, 80);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final ext = prefs.getString('downloadQuality') == 'mp4' ? 'mp4' : 'm4a';
      final file = File('$dirPath/$sanitizedTitle.$ext');

      // If file already exists, mark completed and register
      if (await file.exists()) {
        task.progress.value = 1.0;
        task.state.value = DownloadState.completed;
        LocalLibraryService.registerDownloadedTrack(track);
        return;
      }

      final request = http.Request('GET', Uri.parse(streamUrl));
      final response = await _client.send(request);

      if (response.statusCode != 200) throw Exception('Failed to download: ${response.statusCode}');

      final contentLength = response.contentLength ?? 0;
      int downloaded = 0;

      final sink = file.openWrite();
      
      // Catch errors asynchronously from the sink so they don't crash the app
      sink.done.catchError((e) {
        debugPrint('Sink error for ${track.title}: $e');
        task.state.value = DownloadState.failed;
      });

      await response.stream.listen((chunk) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          task.progress.value = downloaded / contentLength;
        }
      }).asFuture();

      await sink.flush();
      await sink.close();
      task.state.value = DownloadState.completed;
      // Register in the Downloaded Songs playlist
      LocalLibraryService.registerDownloadedTrack(track);
    } catch (e) {
      debugPrint('Download error for ${track.title}: $e');
      task.state.value = DownloadState.failed;
    } finally {
      // Remove from active list after 5 seconds if completed so it doesn't leak memory, 
      // but keep it long enough for UI to show a tick
      Future.delayed(const Duration(seconds: 5), () {
        if (task.state.value == DownloadState.completed) {
          _activeDownloads.remove(track.id);
          downloadEvent.value++;
        }
      });
    }
  }

  Future<void> downloadPlaylist(PlaylistModel playlist, List<TrackModel> tracks) async {
    for (final track in tracks) {
      // Start download immediately (we can process concurrently, but limit it if there are too many)
      downloadTrack(track, playlistName: playlist.title);
      // Slight delay to prevent rate-limiting or hammering the network
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
