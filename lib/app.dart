import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/neko_theme.dart';
import 'state/app_state.dart';
import 'screens/shell_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NekoApp extends StatelessWidget {
  final SharedPreferences prefs;
  const NekoApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      prefs: prefs,
      child: Builder(
        builder: (context) {
          final isAmoled = AppStateProvider.of(context).isAmoledThemeEnabled;
          return MaterialApp(
            title: 'Neko',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: NekoTheme.getTheme(isAmoled),
            home: const ShellScreen(),
          );
        }
      ),
    );
  }
}
