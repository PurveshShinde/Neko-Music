import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';

class LocalLibraryService {
  final SharedPreferences _prefs;
  static const String _playlistsKey = 'local_playlists';
  static const String _playlistTracksPrefix = 'playlist_tracks_';

  LocalLibraryService(this._prefs);

  List<PlaylistModel> getPlaylists() {
    final playlistsJsonStr = _prefs.getStringList(_playlistsKey) ?? [];
    return playlistsJsonStr
        .map((jsonStr) => PlaylistModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _savePlaylists(List<PlaylistModel> playlists) async {
    final playlistsJsonStr = playlists.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_playlistsKey, playlistsJsonStr);
  }

  Future<PlaylistModel> createPlaylist(String title, String subtitle, {String? imageUrl, int colorSeed = 0xFF6C5CE7}) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      colorSeed: colorSeed,
    );

    final playlists = getPlaylists();
    playlists.add(playlist);
    await _savePlaylists(playlists);
    
    // Initialize empty track list
    await _saveTracks(playlist.id, []);
    
    return playlist;
  }

  Future<void> updatePlaylist(PlaylistModel updatedPlaylist) async {
    final playlists = getPlaylists();
    final index = playlists.indexWhere((p) => p.id == updatedPlaylist.id);
    if (index != -1) {
      playlists[index] = updatedPlaylist;
      await _savePlaylists(playlists);
    }
  }

  Future<void> ensureLikedSongsPlaylistExists() async {
    final playlists = getPlaylists();
    if (!playlists.any((p) => p.id == 'liked_songs')) {
      final likedPlaylist = PlaylistModel(
        id: 'liked_songs',
        title: 'Liked Songs',
        subtitle: 'My favorite tracks',
        colorSeed: 0xFFE91E63, // Pinkish for Liked Songs
      );
      playlists.insert(0, likedPlaylist);
      await _savePlaylists(playlists);
      await _saveTracks('liked_songs', []);
    }
  }

  Future<void> ensureDownloadedSongsPlaylistExists() async {
    final playlists = getPlaylists();
    if (!playlists.any((p) => p.id == 'downloaded_songs')) {
      final downloadedPlaylist = PlaylistModel(
        id: 'downloaded_songs',
        title: 'Downloaded Songs',
        subtitle: 'Offline tracks',
        colorSeed: 0xFF4CAF50, // Greenish for Downloads
        spotifyId: 'downloaded_songs',
      );
      // Insert after Liked Songs if it exists, else at 0
      final insertIndex = playlists.any((p) => p.id == 'liked_songs') ? 1 : 0;
      playlists.insert(insertIndex, downloadedPlaylist);
      await _savePlaylists(playlists);
      await _saveTracks('downloaded_songs', []);
    }
  }

  static Future<void> registerDownloadedTrack(TrackModel track) async {
    final prefs = await SharedPreferences.getInstance();
    final localLibrary = LocalLibraryService(prefs);
    await localLibrary.ensureDownloadedSongsPlaylistExists();
    await localLibrary.addTrackToPlaylist('downloaded_songs', track);
  }

  bool isLiked(TrackModel track) {
    final tracks = getTracks('liked_songs');
    return tracks.any((t) => t.title == track.title && t.artist == track.artist);
  }

  Future<bool> toggleLikedSong(TrackModel track) async {
    await ensureLikedSongsPlaylistExists();
    final tracks = getTracks('liked_songs');
    final isCurrentlyLiked = tracks.any((t) => t.title == track.title && t.artist == track.artist);
    
    if (isCurrentlyLiked) {
      tracks.removeWhere((t) => t.title == track.title && t.artist == track.artist);
      await _saveTracks('liked_songs', tracks);
      return false;
    } else {
      tracks.insert(0, track); // Add to top
      await _saveTracks('liked_songs', tracks);
      return true;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists(playlists);
    await _prefs.remove('$_playlistTracksPrefix$playlistId');
  }

  List<TrackModel> getTracks(String playlistId) {
    final tracksJsonStr = _prefs.getStringList('$_playlistTracksPrefix$playlistId') ?? [];
    return tracksJsonStr
        .map((jsonStr) => TrackModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveTracks(String playlistId, List<TrackModel> tracks) async {
    final tracksJsonStr = tracks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList('$_playlistTracksPrefix$playlistId', tracksJsonStr);
  }

  Future<void> addTrackToPlaylist(String playlistId, TrackModel track) async {
    final tracks = getTracks(playlistId);
    // Avoid exact duplicates (assuming title+artist is unique enough for now)
    if (!tracks.any((t) => t.title == track.title && t.artist == track.artist)) {
      tracks.add(track);
      await _saveTracks(playlistId, tracks);
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, TrackModel track) async {
    final tracks = getTracks(playlistId);
    tracks.removeWhere((t) => t.title == track.title && t.artist == track.artist);
    await _saveTracks(playlistId, tracks);
  }
}
