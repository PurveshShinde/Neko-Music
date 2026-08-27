import 'package:flutter/material.dart';
import '../state/app_state.dart';

class ContentSettingsScreen extends StatelessWidget {
  const ContentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Home Screen',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Spotify Recommendations'),
                  subtitle: const Text('Show dynamic content from your Spotify plugins instead of basic recommendations.'),
                  value: state.useSpotifyRecommendations,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (value) {
                    state.useSpotifyRecommendations = value;
                  },
                  secondary: const Icon(Icons.explore_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
