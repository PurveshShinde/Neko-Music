import 'package:flutter/material.dart';
import '../theme/neko_theme.dart';
import '../state/app_state.dart';
import 'album_art_tile.dart';

/// Style A: Solid elevated mini-player (Light Vintage or AMOLED Dark).
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
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;
    final accentColor = NekoColors.accent;

    final bgColor = isAmoled ? const Color(0xFF1E1E1E) : NekoColors.lightSurface;
    final primaryTextColor = isAmoled ? NekoColors.amoledTextPrimary : NekoColors.lightTextPrimary;
    final secondaryTextColor = isAmoled ? NekoColors.amoledTextSecondary : NekoColors.lightTextSecondary;

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAmoled ? Colors.transparent : const Color(0x15000000), 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: isAmoled ? Colors.black.withValues(alpha: 0.8) : const Color(0x15000000),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
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
              color: secondaryTextColor,
              onTap: onPrevious,
              size: 22,
            ),
            const SizedBox(width: 2),
            _ControlButton(
              icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: primaryTextColor,
              onTap: onPlayPause,
              size: 28,
            ),
            const SizedBox(width: 2),
            _ControlButton(
              icon: Icons.skip_next_rounded,
              color: secondaryTextColor,
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
    required this.color,
    this.size = 24,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onTap,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
