import 'dart:ui';
import 'package:flutter/material.dart';
import '../state/app_state.dart';

/// Floating capsule-style bottom navigation bar that supports both solid and glass modes.
class BottomNavCapsule extends StatelessWidget {
  const BottomNavCapsule({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    // Use master toggle to disable all, otherwise use individual toggle
    final isGlass = state.isGlassmorphismEnabled && state.isGlassNavigationBarEnabled;
    final isFloating = state.isFloatingNavigationBarEnabled;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isFloating ? 20 : 0,
        0,
        isFloating ? 20 : 0,
        isFloating ? 24 : 0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isGlass
            ? _GlassBottomNav(
                key: const ValueKey('glass'),
                currentIndex: currentIndex,
                isFloating: isFloating,
                onTap: onTap,
              )
            : _SolidBottomNav(
                key: const ValueKey('solid'),
                currentIndex: currentIndex,
                isFloating: isFloating,
                onTap: onTap,
              ),
      ),
    );
  }
}

class _SolidBottomNav extends StatelessWidget {
  const _SolidBottomNav({
    super.key,
    required this.currentIndex,
    required this.isFloating,
    required this.onTap,
  });

  final int currentIndex;
  final bool isFloating;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Main Capsule
        Expanded(
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF000000), // Solid black
              borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIconItem(
                  icon: Icons.home_filled,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavIconItem(
                  icon: Icons.search_rounded,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavIconItem(
                  icon: Icons.mic_none_rounded,
                  isActive: false,
                  onTap: () {},
                ),
                _NavIconItem(
                  icon: Icons.library_music_outlined,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right Options Button
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: isFloating ? BoxShape.circle : BoxShape.rectangle,
              color: const Color(0xFF1E3A8A), // Blue color from screenshot
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.more_horiz_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.isFloating,
    required this.onTap,
  });

  final int currentIndex;
  final bool isFloating;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left Capsule (Home & Library)
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF281111).withValues(alpha: 0.5), // Glass tinted dark reddish
                  borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavPillItem(
                        icon: Icons.home_filled,
                        label: 'Home',
                        isActive: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavPillItem(
                        icon: Icons.library_music_outlined,
                        label: 'Library',
                        isActive: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right Capsule (Search)
        GestureDetector(
          onTap: () => onTap(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: isFloating ? BoxShape.circle : BoxShape.rectangle,
                  color: const Color(0xFF2A2B3D).withValues(alpha: 0.5), // Glass dark blueish
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: currentIndex == 1
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      size: 28,
                    ),
                    // Decorative dots
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 20,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavIconItem extends StatelessWidget {
  const _NavIconItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? const Color(0xFF2A2A2A) : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _NavPillItem extends StatelessWidget {
  const _NavPillItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
