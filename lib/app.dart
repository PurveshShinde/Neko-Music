import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/slothify_theme.dart';
import 'state/app_state.dart';
import 'screens/shell_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SlothifyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const SlothifyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      prefs: prefs,
      child: Builder(
        builder: (context) {
          final isAmoled = AppStateProvider.of(context).isAmoledThemeEnabled;
          return MaterialApp(
            title: 'Slothify',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: SlothifyTheme.getTheme(isAmoled),
            home: const ShellScreen(),
          );
        }
      ),
    );
  }
}
