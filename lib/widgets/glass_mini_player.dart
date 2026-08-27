import 'package:flutter/material.dart';
import 'album_art_tile.dart';
import 'liquid_glass_container.dart';
import '../theme/neko_theme.dart';

/// Glassmorphism Mini Player matching the Liquid Glass Beta theme.
class GlassMiniPlayer extends StatelessWidget {
  const GlassMiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    required this.emoji,
    required this.colorSeed,
    this.imageUrl,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  final String title;
  final String artist;
  final String emoji;
  final int colorSeed;
  final String? imageUrl;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      height: 60,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Rounded Square Album Art
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: AlbumArtTile(
                emoji: emoji,
                colorSeed: colorSeed,
                imageUrl: imageUrl,
                size: 44,
                borderRadius: 12,
              ),
            ),
            const SizedBox(width: 12),

            // Title & artist
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NekoColors.amoledTextPrimary.withValues(alpha: 0.95),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: NekoColors.amoledTextSecondary.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Controls
            IconButton(
              icon: const Icon(
                Icons.skip_previous_rounded,
                color: NekoColors.amoledTextPrimary,
                size: 26,
              ),
              onPressed: onPrevious,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: NekoColors.amoledTextPrimary,
                size: 28,
              ),
              onPressed: onPlayPause,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.skip_next_rounded,
                color: NekoColors.amoledTextPrimary,
                size: 26,
              ),
              onPressed: onNext,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
