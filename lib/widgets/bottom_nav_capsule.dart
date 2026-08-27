import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/neko_theme.dart';
import 'liquid_glass_container.dart';

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
    final isGlass = state.isGlassmorphismEnabled && state.isGlassNavigationBarEnabled;
    final isFloating = state.isFloatingNavigationBarEnabled;
    final isAmoled = state.isAmoledThemeEnabled;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isFloating ? 16 : 0,
        0,
        isFloating ? 16 : 0,
        isFloating ? 12 : 0,
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
                isAmoled: isAmoled,
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
    required this.isAmoled,
    required this.onTap,
  });

  final int currentIndex;
  final bool isFloating;
  final bool isAmoled;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final capsuleColor = isAmoled ? const Color(0xFF1A1A1A) : NekoColors.lightSurface;
    final activeIconColor = isAmoled ? NekoColors.amoledTextPrimary : NekoColors.lightTextPrimary;
    final inactiveIconColor = isAmoled ? NekoColors.amoledTextSecondary : NekoColors.lightTextSecondary;
    final searchBgColor = isAmoled ? const Color(0xFF2A2A2A) : const Color(0xFFEBE5D8);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: capsuleColor,
        borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
        boxShadow: isFloating
            ? [
                BoxShadow(
                  color: isAmoled ? Colors.black : const Color(0x15000000),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIconItem(
            icon: Icons.home_filled,
            isActive: currentIndex == 0,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(0),
          ),
          _NavIconItem(
            icon: Icons.grid_view_rounded,
            isActive: currentIndex == 1,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(1),
          ),
          _NavIconItem(
            icon: Icons.search_rounded,
            isActive: currentIndex == 2,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(2),
          ),
          _NavIconItem(
            icon: Icons.library_music_outlined,
            isActive: currentIndex == 3,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(3),
          ),
          _NavIconItem(
            icon: Icons.settings_outlined,
            isActive: currentIndex == 4,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(4),
          ),
        ],
      ),
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
    // Glass icons are crisp off-white for AMOLED
    const activeIconColor = NekoColors.amoledTextPrimary;
    const inactiveIconColor = NekoColors.amoledTextSecondary;

    return LiquidGlassContainer(
      height: 64,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(isFloating ? 32 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIconItem(
            icon: Icons.home_filled,
            isActive: currentIndex == 0,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(0),
          ),
          _NavIconItem(
            icon: Icons.grid_view_rounded,
            isActive: currentIndex == 1,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(1),
          ),
          _NavIconItem(
            icon: Icons.search_rounded,
            isActive: currentIndex == 2,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(2),
          ),
          _NavIconItem(
            icon: Icons.library_music_outlined,
            isActive: currentIndex == 3,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(3),
          ),
          _NavIconItem(
            icon: Icons.settings_outlined,
            isActive: currentIndex == 4,
            activeColor: activeIconColor,
            inactiveColor: inactiveIconColor,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavIconItem extends StatelessWidget {
  const _NavIconItem({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        color: Colors.transparent,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}
