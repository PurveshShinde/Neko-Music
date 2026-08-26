import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'appearance_screen.dart';
import 'player_audio_settings_screen.dart';
import 'plugins_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
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
          const SizedBox(height: 24),

          // ── Contiguous Settings Block ──
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F29),
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
                _buildDivider(),
                _buildActionTile(
                  context,
                  iconWidget: _buildAiIcon(),
                  title: 'AI Hub',
                  subtitle: 'AI-powered lyrics and translations',
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Themes, colors, and UI layout',
                  destination: const AppearanceScreen(),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.play_arrow_outlined,
                  title: 'Player and audio',
                  subtitle: 'Playback, quality, and equalizer',
                  destination: const PlayerAudioSettingsScreen(),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.people_outline_rounded,
                  title: 'Listen Together',
                  subtitle: 'Sync playback with friends',
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Content',
                  subtitle: 'Language, region, and providers',
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Privacy',
                  subtitle: 'History and tracking',
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  icon: Icons.extension_outlined,
                  title: 'Spotube Plugins',
                  subtitle: 'Manage metadata and API integrations',
                  destination: const PluginsScreen(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 120), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAiIcon() {
    return Center(
      child: Text(
        'Ai',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget ??
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 24,
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
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
