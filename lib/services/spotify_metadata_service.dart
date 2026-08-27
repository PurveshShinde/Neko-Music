import 'package:flutter/material.dart';
import 'package:hetu_script/values.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../services/plugin_manager_service.dart';
import '../services/youtube_search_service.dart';
import '../theme/neko_theme.dart';

class SpotifyMetadataService {
  final PluginManagerService pluginManager;
  SpotifyMetadataService(this.pluginManager);

  List<dynamic>? _cachedSections;
  DateTime? _lastFetch;

  void clearCache() {
    _cachedSections = null;
    _lastFetch = null;
  }

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
      if (seedTrack.videoId != null) {
        return ytService.getRelatedTracks(seedTrack.videoId!);
      }
      return ytService.searchTracks('similar to ${seedTrack.title} ${seedTrack.artist}');
    }

    try {
      await _ensureAuthenticated(engine);
      
      // Attempt to invoke plugin's native radio if available
      try {
        final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
        final trackEndpoint = metadataPlugin.memberGet("track") as HTInstance;
        final raw = await trackEndpoint.invoke(
          "radio",
          positionalArgs: [seedTrack.spotifyId],
        ) as List?;
        
        final items = raw ?? [];
        return _mapTracks(items.toList());
      } catch (e) {
        debugPrint('Radio fetch failed, falling back to YouTube: $e');
        if (seedTrack.videoId != null) {
          return ytService.getRelatedTracks(seedTrack.videoId!);
        }
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
        id: pMap['id'] as String? ?? pMap['name'] as String? ?? 'playlist',
        title: pMap['name'] as String? ?? 'Playlist',
        subtitle: pMap['description'] as String? ?? 'Spotify Playlist',
        imageUrl: (pMap['images'] as List?)?.isNotEmpty == true ? (pMap['images'] as List)[0]['url'] as String? : null,
        colorSeed: NekoColors.colorFromTitle(pMap['name'] as String? ?? 'Playlist').toARGB32(),
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

      final isSectionAlbum = title.toLowerCase().contains('album');
      
      final playlists = validItems.map((p) {
        final pMap = p as Map;
        
        final isAlbumCheck = isSectionAlbum ||
                   pMap['type']?.toString().toLowerCase() == 'album' || 
                   (pMap['uri'] as String?)?.contains(':album:') == true ||
                   (pMap['id'] as String?)?.contains(':album:') == true ||
                   pMap.containsKey('artists');
                   
        if (!isAlbumCheck) {
          debugPrint('[SpotifyMetadataService] Item is NOT an album: ${pMap.toString()}');
        } else {
          debugPrint('[SpotifyMetadataService] Item IS an album: ${pMap.toString()}');
        }

        String? img;
        final images = pMap['images'] as List? ?? pMap['icons'] as List?;
        if (images != null && images.isNotEmpty) {
          img = images[0]['url'] as String?;
        } else if (pMap['cover'] is String) {
          img = pMap['cover'] as String?;
        } else if (pMap['album'] is Map && (pMap['album'] as Map)['images'] is List && ((pMap['album'] as Map)['images'] as List).isNotEmpty) {
          img = ((pMap['album'] as Map)['images'] as List)[0]['url'] as String?;
        }

        return PlaylistModel(
          id: pMap['id'] as String? ?? pMap['name'] as String? ?? 'playlist',
          title: pMap['name'] as String? ?? 'Unknown',
          subtitle: pMap['description'] as String? ?? 
                    (pMap['owner'] != null ? 'By ${(pMap['owner'] as Map)['name']}' : 
                     (pMap.containsKey('artists') && (pMap['artists'] as List).isNotEmpty ? 'Album by ${(pMap['artists'] as List)[0]['name']}' : 'Spotify Playlist')),
          imageUrl: img,
          colorSeed: NekoColors.colorFromTitle(pMap['name'] as String? ?? 'Unknown').toARGB32(),
          spotifyId: pMap['id'] as String?,
          isAlbum: isAlbumCheck,
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

      final cleanId = playlistId.replaceAll('spotify:playlist:', '');
      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final playlistEndpoint = metadataPlugin.memberGet("playlist") as HTInstance;
      try {
        final token = engine.eval("metadataPlugin.auth.token");
        debugPrint('SPOTIFY TOKEN: $token');
      } catch (e) {
        debugPrint('SPOTIFY TOKEN ERROR: $e');
      }
      final raw = await playlistEndpoint.invoke(
        "tracks",
        positionalArgs: [cleanId],
        namedArgs: {"limit": 100, "offset": 0},
      ) as Map;
      final items = raw['items'] as List? ?? [];
      return _mapTracks(items);
    } catch (e) {
      debugPrint('Error fetching playlist tracks: $e');
      return [];
    }
  }

  Future<List<TrackModel>> getAlbumTracks(String albumId) async {
    final engine = pluginManager.getMetadataEngine();
    if (engine == null) throw Exception('No metadata plugin loaded');

    try {
      await _ensureAuthenticated(engine);

      final cleanId = albumId.replaceAll('spotify:album:', '');
      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final albumEndpoint = metadataPlugin.memberGet("album") as HTInstance;
      final raw = await albumEndpoint.invoke(
        "tracks",
        positionalArgs: [cleanId],
        namedArgs: {"limit": 50, "offset": 0},
      ) as Map;
      
      final items = raw['items'] as List? ?? [];
      return _mapTracks(items);
    } catch (e) {
      debugPrint('Error fetching album tracks: $e');
      return [];
    }
  }

  List<TrackModel> _mapTracks(List<dynamic> tracks) {
    return tracks.where((t) => t != null && t is Map).map((t) {
      final item = t as Map;
      final track = (item.containsKey('track') ? item['track'] : item) as Map;
      debugPrint('TRACK ITEM KEYS: ${track.keys.toList()}');
      if (track.containsKey('duration_ms')) debugPrint('duration_ms: ${track['duration_ms']}');
      if (track.containsKey('durationMs')) debugPrint('durationMs: ${track['durationMs']}');
      if (track.containsKey('duration')) debugPrint('duration: ${track['duration']}');
      
      final durationMs = (track['duration_ms'] as int?) ?? (track['durationMs'] as int?) ?? 0;
      final durationSecs = durationMs ~/ 1000;
      String duration = Duration(seconds: durationSecs).toString().split('.').first;
      if (duration.startsWith('0:')) {
        duration = duration.substring(2);
      }
      
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
        colorSeed: NekoColors.colorFromTitle(track['name'] as String? ?? 'Unknown').toARGB32(),
        imageUrl: imageUrl,
        duration: duration,
        spotifyId: track['id'] as String?,
        isExplicit: track['explicit'] as bool? ?? false,
      );
    }).toList();
  }
}
