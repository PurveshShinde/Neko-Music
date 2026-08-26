import 'package:flutter/material.dart';

/// Procedurally-generated album art placeholder.
///
/// Uses the [colorSeed] to build a gradient background and renders
/// a large [emoji] in the center so the UI is visually rich without
/// needing actual image assets.
class AlbumArtTile extends StatelessWidget {
  const AlbumArtTile({
    super.key,
    required this.emoji,
    required this.colorSeed,
    this.imageUrl,
    this.size = 56,
    this.borderRadius = 12,
  });

  final String emoji;
  final int colorSeed;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final baseColor = Color(colorSeed);
    final darkVariant = HSLColor.fromColor(baseColor)
        .withLightness(0.18)
        .withSaturation(0.6)
        .toColor();
    final midVariant = HSLColor.fromColor(baseColor)
        .withLightness(0.30)
        .withSaturation(0.55)
        .toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [midVariant, darkVariant],
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.38),
        ),
      ),
    );
  }
}
