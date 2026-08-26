import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListenTogetherSettingsScreen extends StatefulWidget {
  const ListenTogetherSettingsScreen({super.key});

  @override
  State<ListenTogetherSettingsScreen> createState() =>
      _ListenTogetherSettingsScreenState();
}

class _ListenTogetherSettingsScreenState
    extends State<ListenTogetherSettingsScreen> {
  bool _autoApprove = false;
  bool _syncHostVolume = true;
  bool _smartNetworkResync = true;

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
          'Listen Together',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Disconnect',
              style: TextStyle(
                color: Color(0xFFA5B4FC), // Light blue text color
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFFA5B4FC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ── Settings Container ──
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F29),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Blocked Users',
                  subtitle: 'No blocked users',
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.cloud_queue_rounded,
                  title: 'Server URL',
                  subtitle: 'slothify Server - Global - slothify...',
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Username',
                  subtitle: 'Ciel',
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.check_rounded,
                  title: 'Auto-approve join requests',
                  subtitle:
                      'Automatically approve join requests instead of reviewing them manually',
                  trailing: CupertinoSwitch(
                    value: _autoApprove,
                    activeColor: const Color(0xFF1E3A8A),
                    trackColor: Colors.white.withValues(alpha: 0.1),
                    onChanged: (val) => setState(() => _autoApprove = val),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sync host volume',
                  subtitle: 'Guests follow the host volume level',
                  trailing: CupertinoSwitch(
                    value: _syncHostVolume,
                    activeColor: const Color(0xFF1E3A8A),
                    trackColor: Colors.white.withValues(alpha: 0.1),
                    onChanged: (val) => setState(() => _syncHostVolume = val),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.route_outlined, // closest to resync icon
                  title: 'Smart Network Resync',
                  subtitle:
                      'Automatically catch up with the host after a connection drop',
                  trailing: CupertinoSwitch(
                    value: _smartNetworkResync,
                    activeColor: const Color(0xFF1E3A8A),
                    trackColor: Colors.white.withValues(alpha: 0.1),
                    onChanged: (val) => setState(() => _smartNetworkResync = val),
                  ),
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.bug_report_outlined,
                  title: 'View logs',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.black.withValues(alpha: 0.3),
      height: 1,
      thickness: 1,
      indent: 64, // indent past the icon
      endIndent: 16,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                if (subtitle == null) const SizedBox(height: 12), // center single line
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
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ] else if (subtitle == null) ...[
             const SizedBox(height: 48), // ensure min height
          ]
        ],
      ),
    );
  }
}
