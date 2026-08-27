import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/neko_theme.dart';

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
      final isNetwork = imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://');
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image: isNetwork ? NetworkImage(imageUrl!) as ImageProvider : FileImage(File(imageUrl!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final isAmoled = Theme.of(context).brightness == Brightness.dark;
    Color baseColor = Color(colorSeed);
    Color darkVariant;
    Color midVariant;

    if (isAmoled) {
      darkVariant = HSLColor.fromColor(baseColor).withLightness(0.18).withSaturation(0.6).toColor();
      midVariant = HSLColor.fromColor(baseColor).withLightness(0.30).withSaturation(0.55).toColor();
    } else {
      baseColor = baseColor.toCalmColor();
      darkVariant = HSLColor.fromColor(baseColor).withLightness(0.80).withSaturation(0.3).toColor();
      midVariant = HSLColor.fromColor(baseColor).withLightness(0.90).withSaturation(0.25).toColor();
    }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final actualSize = size == double.infinity ? constraints.maxWidth : size;
            return Text(
              emoji,
              style: TextStyle(fontSize: actualSize * 0.38),
            );
          },
        ),
      ),
    );
  }
}
