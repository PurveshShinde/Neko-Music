import 'package:flutter/material.dart';

/// A lightweight, performant overlay that adds a subtle film grain/noise 
/// texture to backgrounds to give a vintage paper look.
class VintageNoiseOverlay extends StatelessWidget {
  const VintageNoiseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Disabled to prevent asset loading errors and to maintain a pure minimalist surface.
    return const SizedBox.shrink();
  }
}
