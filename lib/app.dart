import 'package:flutter/material.dart';
import 'theme/slothify_theme.dart';
import 'state/app_state.dart';
import 'screens/shell_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SlothifyApp extends StatelessWidget {
  const SlothifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      child: MaterialApp(
        title: 'Slothify',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: SlothifyTheme.darkTheme,
        home: const ShellScreen(),
      ),
    );
  }
}
