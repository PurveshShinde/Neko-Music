import 'package:flutter/material.dart';
import '../theme/slothify_theme.dart';
import 'album_art_tile.dart';

/// Style A: Solid dark elevated mini-player.
class StandardMiniPlayer extends StatelessWidget {
  const StandardMiniPlayer({
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
    final accentColor = Color(colorSeed);

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: SlothifyColors.miniPlayerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SlothifyColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // Album thumbnail
            AlbumArtTile(
              emoji: emoji,
              colorSeed: colorSeed,
              imageUrl: imageUrl,
              size: 48,
              borderRadius: 10,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SlothifyColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: SlothifyColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Controls
            _ControlButton(
              icon: Icons.skip_previous_rounded,
              onTap: onPrevious,
              size: 22,
            ),
            const SizedBox(width: 2),
            // Play / Pause – accent circle
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SlothifyColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: SlothifyColors.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 2),
            _ControlButton(
              icon: Icons.skip_next_rounded,
              onTap: onNext,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 24,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: SlothifyColors.textSecondary),
      onPressed: onTap,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
