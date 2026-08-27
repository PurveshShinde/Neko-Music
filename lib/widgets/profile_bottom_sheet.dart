import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for Profile and Settings
class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  bool _useAccountBrowsing = true;
  bool _youtubeSync = false;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'neko',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              // ── Account Section ──
              _buildSectionHeader('Account'),
              _buildListTile(
                icon: Icons.account_circle_outlined,
                title: 'Nick Wilde',
                subtitle: 'Logged In',
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('https://picsum.photos/seed/avatar/100/100'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // ── Preferences Section ──
              _buildSectionHeader('Preferences'),
              _buildListTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'Use Account for Browsing',
                trailing: CupertinoSwitch(
                  value: _useAccountBrowsing,
                  activeTrackColor: const Color(0xFF1E3A8A), // Match the blue from nav
                  onChanged: (val) => setState(() => _useAccountBrowsing = val),
                ),
              ),
              const SizedBox(height: 8),
              _buildListTile(
                icon: Icons.sync_rounded,
                title: 'YouTube Music Sync',
                trailing: CupertinoSwitch(
                  value: _youtubeSync,
                  activeTrackColor: const Color(0xFF1E3A8A),
                  onChanged: (val) => setState(() => _youtubeSync = val),
                ),
              ),

              const SizedBox(height: 24),
              // ── App Section ──

              _buildListTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                trailing: Text(
                  '5.2.89',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // Footer
              Text(
                'Privacy Policy  •  Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    Widget? iconWidget,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: iconWidget ??
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 26,
            ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}
