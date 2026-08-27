import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/neko_theme.dart';
import 'vintage_noise_overlay.dart';

/// The tri-theme background layer.
/// 
/// - Theme 1 (Minimalist Light Vintage): Clean cream parchment with a subtle texture.
/// - Theme 2 & 3 (AMOLED/Liquid Glass): True AMOLED black.
class DynamicAppBackground extends StatelessWidget {
  final Widget child;

  const DynamicAppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;

    return Stack(
      children: [
        // Base Solid Color
        Container(
          color: isAmoled ? NekoColors.amoledBackground : NekoColors.lightBackground,
        ),
        
        // Vintage Paper Texture (only on Light Vintage theme)
        if (!isAmoled)
          const VintageNoiseOverlay(),

        // The main content sits safely on top
        child,
      ],
    );
  }
}
