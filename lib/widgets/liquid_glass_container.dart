import 'dart:ui';
import 'package:flutter/material.dart';

/// A heavily layered, complex glass container for the "Beta AMOLED Glassmorphism" theme.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final finalBorderRadius = shape == BoxShape.circle 
        ? null 
        : (borderRadius ?? BorderRadius.circular(24));

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: finalBorderRadius,
        boxShadow: [
          // Complex spread-out shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8), // Very dark shadow for AMOLED
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: finalBorderRadius ?? BorderRadius.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── 1. Clear Glass Layer (High Blur, low fill) ──
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05), // 5% fill
                    shape: shape,
                    borderRadius: finalBorderRadius,
                  ),
                ),
              ),
            ),

            // ── 2. Frosted Glass Layer (Medium blur, milky tint) ──
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10), // 10% fill
                    shape: shape,
                    borderRadius: finalBorderRadius,
                  ),
                ),
              ),
            ),

            // ── 3. Internal Refractions & Specular Highlights (Custom Painter) ──
            Positioned.fill(
              child: CustomPaint(
                painter: _GlassBorderPainter(
                  shape: shape,
                  borderRadius: finalBorderRadius as BorderRadius?,
                ),
              ),
            ),

            // ── 4. Content ──
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBorderPainter extends CustomPainter {
  final BoxShape shape;
  final BorderRadius? borderRadius;

  _GlassBorderPainter({required this.shape, this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Gradient for the sharp specular highlight
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFDF99).withValues(alpha: 0.8), // Warm gold top-left
        Colors.white.withValues(alpha: 0.4),
        Colors.transparent,
        Colors.black.withValues(alpha: 0.3), // Darker bottom-right
      ],
      stops: const [0.0, 0.2, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.width / 2, paint);
    } else {
      final rrect = (borderRadius ?? BorderRadius.circular(24)).toRRect(rect);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
