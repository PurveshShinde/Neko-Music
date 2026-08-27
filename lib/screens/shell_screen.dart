import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav_capsule.dart';
import '../widgets/mini_player_widget.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import '../widgets/dynamic_app_background.dart';

/// Root shell that holds the bottom nav, mini-player overlay, and page body.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    BrowseScreen(),
    SearchScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return DynamicAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Allow content to scroll under the bottom nav
        body: IndexedStack(
          index: state.currentNavIndex,
          children: _pages,
        ),
      // Stack mini-player + bottom nav at the bottom.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Mini Player ──
            const MiniPlayerWidget(),
            // ── Bottom Navigation ──
            BottomNavCapsule(
              currentIndex: state.currentNavIndex,
              onTap: (i) => state.currentNavIndex = i,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
