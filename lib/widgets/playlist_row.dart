import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../screens/playlist_screen.dart';
import 'skeleton_ui.dart';

/// Horizontal scrollable row of playlist cards.
class PlaylistRow extends StatelessWidget {
  final List<PlaylistModel> playlists;
  const PlaylistRow({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const SizedBox();

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _PlaylistCard(playlist: playlists[index]);
        },
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});
  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(playlist.colorSeed);
    final darkColor = HSLColor.fromColor(baseColor)
        .withLightness(0.15)
        .withSaturation(0.5)
        .toColor();
    final lightColor = HSLColor.fromColor(baseColor)
        .withLightness(0.30)
        .withSaturation(0.45)
        .toColor();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistScreen(playlist: playlist),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist cover
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [lightColor, darkColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                image: playlist.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(playlist.imageUrl!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.3),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),
              child: playlist.imageUrl == null
                  ? Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: baseColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: -10,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: baseColor.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        // Icon
                        Center(
                          child: Text(
                            playlist.title[0],
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              playlist.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
