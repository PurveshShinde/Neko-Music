import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _moreContent = true;
  bool _autoSync = false;
  bool _listenBrainz = false;

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
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Settings ──
          _buildSectionHeader('Settings'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F29),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('https://picsum.photos/seed/nick/200/200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Nick Wilde',
                    style: TextStyle(
                      color: Color(0xFFA5B4FC), // Light blue text color
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Login with token ──
          _buildSectionHeader('Login with token'),
          _buildTileGroup([
            _buildActionTile(
              icon: Icons.integration_instructions_outlined,
              title: 'Tap to show token',
            ),
          ]),
          const SizedBox(height: 24),

          // ── Player & Content ──
          _buildSectionHeader('Player & Content'),
          _buildTileGroup([
            _buildSwitchTile(
              icon: Icons.add_circle_outline,
              title: 'More content',
              subtitle: 'Manage More content settings',
              value: _moreContent,
              onChanged: (val) => setState(() => _moreContent = val),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.sync_rounded,
              title: 'Auto sync with account',
              subtitle: 'Manage Auto sync with account settings',
              value: _autoSync,
              onChanged: (val) => setState(() => _autoSync = val),
            ),
          ]),
          const SizedBox(height: 24),

          // ── Integrations ──
          _buildSectionHeader('Integrations'),
          _buildTileGroup([
            _buildActionTile(
              icon: Icons.discord,
              title: 'Discord Integration',
              subtitle: 'Manage Discord Integration settings',
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.headset, // Placeholder for last.fm
              title: 'Last.fm Integration',
              subtitle: 'Manage Last.fm Integration settings',
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.library_music_outlined, // Placeholder for LB
              title: 'ListenBrainz scrobbling',
              subtitle: 'Manage ListenBrainz scrobbling settings',
              value: _listenBrainz,
              onChanged: (val) => setState(() => _listenBrainz = val),
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.edit_outlined,
              title: 'Set ListenBrainz Token',
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFA5B4FC), // Light blue from screenshots
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTileGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F29),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withValues(alpha: 0.3),
      height: 1,
      thickness: 1,
      indent: 64, // past icon
      endIndent: 16,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: subtitle != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
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
                  if (subtitle == null) const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (subtitle == null) const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF1E3A8A), // Bright blue
            trackColor: Colors.white.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
