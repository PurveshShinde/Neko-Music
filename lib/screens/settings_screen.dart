import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'appearance_screen.dart';
import 'player_audio_settings_screen.dart';
import 'plugins_screen.dart';
import 'content_settings_screen.dart';
import 'download_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // ── Contiguous Settings Block ──
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.account_circle_outlined,
                  title: 'Account',
                  subtitle: 'Manage login and integrations',
                  destination: const AccountScreen(),
                ),
                _buildDivider(context),

                _buildActionTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Themes, colors, and UI layout',
                  destination: const AppearanceScreen(),
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.extension_outlined,
                  title: 'Plugins',
                  subtitle: 'Manage audio and metadata plugins',
                  destination: const PluginsScreen(),
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.play_arrow_outlined,
                  title: 'Player and audio',
                  subtitle: 'Playback, quality, and equalizer',
                  destination: const PlayerAudioSettingsScreen(),
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.people_outline_rounded,
                  title: 'Listen Together',
                  subtitle: 'Sync playback with friends',
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Content',
                  subtitle: 'Language, region, and providers',
                  destination: const ContentSettingsScreen(),
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.download_rounded,
                  title: 'Downloads',
                  subtitle: 'Quality and location preferences',
                  destination: const DownloadSettingsScreen(),
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Privacy',
                  subtitle: 'History and tracking',
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.music_note,
                  title: 'Spotify Integration',
                  subtitle: 'Connect Spotify API for high-res covers',
                ),
              ],
            ),
          ),
          
          SizedBox(height: 120), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAiIcon(BuildContext context) {
    return Center(
      child: Text(
        'Ai',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      height: 1,
      thickness: 1,
      indent: 0,
      endIndent: 0,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    Widget? destination,
  }) {
    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget ??
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 24,
                  ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
