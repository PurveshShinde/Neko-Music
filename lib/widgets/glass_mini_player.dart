import 'dart:ui';
import 'package:flutter/material.dart';
import 'album_art_tile.dart';

/// Glassmorphism Mini Player matching the new screenshot
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
    required this.onPrevious, // Ignored in glass layout
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24), // Pill shape but slightly boxy? We'll use pill shape
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black.withValues(alpha: 0.4), // Dark translucent background
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              // Subtle gradient glow based on album color
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accentColor.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
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
                              color: Colors.white.withValues(alpha: 0.95),
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
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Controls - Only Play and Next
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
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
                        color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }
}
