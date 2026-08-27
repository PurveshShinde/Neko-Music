import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../state/app_state.dart';
import 'album_art_tile.dart';

class PlaylistGridCover extends StatelessWidget {
  final PlaylistModel playlist;
  final double size;
  final double borderRadius;

  const PlaylistGridCover({
    super.key,
    required this.playlist,
    this.size = 160,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (playlist.id == 'liked_songs') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF450AF5), // Deep purple-indigo
              Color(0xFF8E8CD8), // Soft periwinkle/blue
            ],
          ),
        ),
        child: Center(
          child: Icon(Icons.favorite, color: Colors.white, size: size.isInfinite ? 48 : size * 0.4),
        ),
      );
    }

    if (playlist.id == 'downloaded_songs') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20), // Deep green
              Color(0xFF66BB6A), // Light green
            ],
          ),
        ),
        child: Center(
          child: Icon(Icons.download_done_rounded, color: Colors.white, size: size.isInfinite ? 48 : size * 0.4),
        ),
      );
    }

    // If it's a Spotify playlist or has an image, just show the standard cover
    if ((playlist.spotifyId != null && playlist.spotifyId != 'liked_songs' && playlist.spotifyId != 'downloaded_songs') || playlist.query != null || playlist.imageUrl != null) {
      return AlbumArtTile(
        emoji: '🎵',
        colorSeed: playlist.colorSeed,
        imageUrl: playlist.imageUrl,
        size: size,
        borderRadius: borderRadius,
      );
    }

    // It's a personal playlist
    final localLibrary = AppStateProvider.of(context).localLibrary;
    final tracks = localLibrary.getTracks(playlist.id);

    if (tracks.isEmpty) {
      return AlbumArtTile(
        emoji: '🎵',
        colorSeed: playlist.colorSeed,
        imageUrl: null,
        size: size,
        borderRadius: borderRadius,
      );
    }

    if (tracks.length < 4) {
      // Show first track's cover
      return AlbumArtTile(
        emoji: tracks.first.albumArt,
        colorSeed: tracks.first.colorSeed,
        imageUrl: tracks.first.imageUrl,
        size: size,
        borderRadius: borderRadius,
      );
    }

    // Show 2x2 grid
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(tracks[0].imageUrl, tracks[0].colorSeed)),
                  Expanded(child: _buildImage(tracks[1].imageUrl, tracks[1].colorSeed)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(tracks[2].imageUrl, tracks[2].colorSeed)),
                  Expanded(child: _buildImage(tracks[3].imageUrl, tracks[3].colorSeed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, int colorSeed) {
    if (imageUrl != null) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
    return Container(color: Color(colorSeed));
  }
}
