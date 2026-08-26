import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hetu_script/values.dart';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../state/app_state.dart';
import '../services/youtube_search_service.dart';

class SpotifyMetadataService {
  final PluginManagerService pluginManager;
  SpotifyMetadataService(this.pluginManager);

  List<dynamic>? _cachedSections;
  DateTime? _lastFetch;

  /// Ensure the Spotify token is valid. If expired, refresh it automatically.
  Future<void> _ensureAuthenticated(dynamic engine) async {
    try {
      final isAuth = engine.eval("metadataPlugin.auth.isAuthenticated()") as bool;
      if (!isAuth) {
        debugPrint('[SpotifyMetadataService] Token expired, refreshing...');
        await engine.eval("metadataPlugin.auth.refreshCredentials()");
        debugPrint('[SpotifyMetadataService] Token refreshed successfully.');
      }
    } catch (e) {
      debugPrint('[SpotifyMetadataService] Auth check/refresh failed: $e');
      // Don't rethrow — let the actual API call fail with a proper error if needed
    }
  }

  Future<List<TrackModel>> getRecommendations() async {
    final sections = await _fetchSections();
    if (sections.isEmpty) return [];
    
    for (final section in sections) {
      final items = section['items'] as List? ?? [];
      final playlists = items.where((i) => i is Map && (i.containsKey('owner') || i.containsKey('collaborative'))).toList();
      if (playlists.isNotEmpty) {
        final playlistId = playlists.first['id'] as String;
        return getPlaylistTracks(playlistId);
      }
    }
    return [];
  }
  
  /// Recommendation Core: gets similar tracks for auto-play when queue finishes
  Future<List<TrackModel>> getSimilarTracks(TrackModel seedTrack) async {
    final engine = pluginManager.getMetadataEngine();
    
    // Fallback search service
    final ytService = YouTubeSearchService();

    if (seedTrack.spotifyId == null || engine == null) {
      // Fallback to searching YouTube for similar tracks
      return ytService.searchTracks('similar to ${seedTrack.title} ${seedTrack.artist}');
    }

    try {
      await _ensureAuthenticated(engine);
      
      // Attempt to invoke plugin's native recommendations if available
      try {
        final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
        final browseEndpoint = metadataPlugin.memberGet("browse") as HTInstance;
        final raw = await browseEndpoint.invoke(
          "recommendations",
          namedArgs: {"seed_tracks": seedTrack.spotifyId, "limit": 10},
        ) as Map;
        final items = raw['tracks'] as List? ?? [];
        return _mapTracks(items.map((t) => {'track': t}).toList());
      } catch (_) {
        // Method might not exist on the plugin, fallback to YouTube
        return ytService.searchTracks('similar to ${seedTrack.title} ${seedTrack.artist}');
      }
    } catch (e) {
      debugPrint('Error fetching similar tracks: $e');
      return [];
    }
  }
  Future<List<TrackModel>> getNewReleases() async {
    final sections = await _fetchSections();
    if (sections.isEmpty) return [];
    
    for (final section in sections.reversed) {
      final items = section['items'] as List? ?? [];
      final playlists = items.where((i) => i is Map && (i.containsKey('owner') || i.containsKey('collaborative'))).toList();
      if (playlists.isNotEmpty) {
        final playlistId = playlists.last['id'] as String;
        return getPlaylistTracks(playlistId);
      }
    }
    return [];
  }

  Future<List<PlaylistModel>> getFeaturedPlaylists() async {
    final sections = await _fetchSections();
    if (sections.isEmpty) return [];

    List<dynamic> allPlaylists = [];
    for (final section in sections) {
      final items = section['items'] as List? ?? [];
      allPlaylists.addAll(items.where((i) => i is Map && (i.containsKey('owner') || i.containsKey('collaborative'))));
    }
    
    return allPlaylists.map((p) {
      final pMap = p as Map;
      return PlaylistModel(
        title: pMap['name'] as String? ?? 'Playlist',
        subtitle: pMap['description'] as String? ?? 'Spotify Playlist',
        imageUrl: (pMap['images'] as List?)?.isNotEmpty == true ? (pMap['images'] as List)[0]['url'] as String? : null,
        colorSeed: 0xFF1DB954,
        spotifyId: pMap['id'] as String?,
      );
    }).toList();
  }

  /// Fetches raw sections from Spotify and parses them into a structured format
  /// containing the section title and a list of PlaylistModels.
  Future<List<Map<String, dynamic>>> getHomeSections() async {
    final sections = await _fetchSections();
    if (sections.isEmpty) return [];

    List<Map<String, dynamic>> structuredSections = [];
    for (final section in sections) {
      final title = section['title'] as String? ?? section['name'] as String? ?? 'Section';
      final items = section['items'] as List? ?? [];
      
      // Map all items that look like playlists/albums to PlaylistModel
      final validItems = items.where((i) => i is Map && i['id'] != null).toList();
      if (validItems.isEmpty) continue;

      final playlists = validItems.map((p) {
        final pMap = p as Map;
        return PlaylistModel(
          title: pMap['name'] as String? ?? 'Unknown',
          subtitle: pMap['description'] as String? ?? (pMap['owner'] != null ? 'By ${(pMap['owner'] as Map)['name']}' : 'Spotify Playlist'),
          imageUrl: (pMap['images'] as List?)?.isNotEmpty == true ? (pMap['images'] as List)[0]['url'] as String? : null,
          colorSeed: 0xFF1DB954,
          spotifyId: pMap['id'] as String?,
        );
      }).toList();

      structuredSections.add({
        'title': title,
        'items': playlists,
      });
    }

    return structuredSections;
  }

  static Future<List<dynamic>>? _fetchingFuture;

  Future<List<dynamic>> _fetchSections() async {
    if (_cachedSections != null && _lastFetch != null && DateTime.now().difference(_lastFetch!).inMinutes < 5) {
      return _cachedSections!;
    }
    
    if (_fetchingFuture != null) {
      return await _fetchingFuture!;
    }

    _fetchingFuture = _doFetchSections();
    try {
      final res = await _fetchingFuture!;
      return res;
    } finally {
      _fetchingFuture = null;
    }
  }

  Future<List<dynamic>> _doFetchSections() async {
    final engine = pluginManager.getMetadataEngine();
    if (engine == null) {
      return [];
    }

    try {
      // Ensure token is valid before making API calls
      await _ensureAuthenticated(engine);

      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final browseEndpoint = metadataPlugin.memberGet("browse") as HTInstance;
      final raw = await browseEndpoint.invoke(
        "sections",
        namedArgs: {"limit": 10, "offset": 0},
      ) as Map;
      
      _cachedSections = raw['items'] as List? ?? [];
      _lastFetch = DateTime.now();
      return _cachedSections!;
    } catch (e, stack) {
      debugPrint('Error fetching sections: $e\n$stack');
      // If it's a 401, try refreshing and retrying once
      if (e.toString().contains('401')) {
        try {
          debugPrint('[SpotifyMetadataService] Got 401, force-refreshing token...');
          await engine.eval("metadataPlugin.auth.refreshCredentials()");
          
          final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
          final browseEndpoint = metadataPlugin.memberGet("browse") as HTInstance;
          final raw = await browseEndpoint.invoke(
            "sections",
            namedArgs: {"limit": 10, "offset": 0},
          ) as Map;
          
          _cachedSections = raw['items'] as List? ?? [];
          _lastFetch = DateTime.now();
          return _cachedSections!;
        } catch (retryError) {
          debugPrint('Retry after refresh also failed: $retryError');
        }
      }
      return [];
    }
  }

  Future<List<TrackModel>> getPlaylistTracks(String playlistId) async {
    final engine = pluginManager.getMetadataEngine();
    if (engine == null) throw Exception('No metadata plugin loaded');

    try {
      await _ensureAuthenticated(engine);

      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final playlistEndpoint = metadataPlugin.memberGet("playlist") as HTInstance;
      final raw = await playlistEndpoint.invoke(
        "tracks",
        positionalArgs: [playlistId],
        namedArgs: {"limit": 15, "offset": 0},
      ) as Map;
      final items = raw['items'] as List? ?? [];
      return _mapTracks(items);
    } catch (e) {
      debugPrint('Error fetching playlist tracks: $e');
      return [];
    }
  }

  List<TrackModel> _mapTracks(List<dynamic> tracks) {
    return tracks.where((t) => t != null && t is Map).map((t) {
      final item = t as Map;
      final track = (item.containsKey('track') ? item['track'] : item) as Map;
      final durationMs = track['durationMs'] as int? ?? 0;
      final durationSecs = durationMs ~/ 1000;
      final duration = Duration(seconds: durationSecs).toString().split('.').first.replaceFirst('0:', '');
      
      final artists = track['artists'] as List? ?? [];
      final artistName = artists.isNotEmpty ? (artists[0] as Map)['name'] as String? ?? 'Unknown' : 'Unknown';
      
      final album = track['album'] as Map?;
      final imageUrl = (album != null && album['images'] != null && (album['images'] as List).isNotEmpty) 
          ? (album['images'] as List)[0]['url'] as String? 
          : null;

      return TrackModel(
        title: track['name'] as String? ?? 'Unknown',
        artist: artistName,
        albumArt: '🎵',
        colorSeed: 0xFF1DB954,
        imageUrl: imageUrl,
        duration: duration,
        spotifyId: track['id'] as String?,
        isExplicit: track['explicit'] as bool? ?? false,
      );
    }).toList();
  }
}
