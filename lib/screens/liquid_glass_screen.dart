import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';

class LiquidGlassScreen extends StatelessWidget {
  const LiquidGlassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Liquid Glass (Beta)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Navigation Bar Style ──
          _buildSectionHeader(context, 'Navigation Bar Style'),
          _buildTileGroup(context, [
            _buildSwitchTile(
              context: context,
              icon: Icons.horizontal_split_rounded,
              title: 'Floating navigation bar',
              subtitle: 'iOS-style floating tab bar that shrinks while scrolling',
              value: state.isFloatingNavigationBarEnabled,
              onChanged: (val) => state.isFloatingNavigationBarEnabled = val,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Liquid Glass (Beta) ──
          _buildSectionHeader(context, 'Liquid Glass (Beta)'),
          _buildTileGroup(context, [
            _buildSwitchTile(
              context: context,
              icon: Icons.check_rounded,
              title: 'Enable Liquid Glass',
              subtitle:
                  'Rendering Liquid Glass is resource-intensive and may reduce smoothness and battery life on some devices',
              value: state.isGlassmorphismEnabled,
              onChanged: (val) => state.isGlassmorphismEnabled = val,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Effects ──
          _buildSectionHeader(context, 'Effects'),
          _buildTileGroup(context, [
            _buildActionTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Vibrancy',
              subtitle: 'Boost the saturation of the glass backdrop',
            ),
            _buildDivider(context),
            _buildActionTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Blur Radius',
              subtitle: 'Amount of blur on the glass surface',
            ),
            _buildDivider(context),
            _buildActionTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Lens Refraction Height',
              subtitle: 'Manage Lens Refraction Height settings',
            ),
            _buildDivider(context),
            _buildActionTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Lens Refraction Amount',
              subtitle: 'Manage Lens Refraction Amount settings',
            ),
            _buildDivider(context),
            _buildSwitchTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Chromatic Aberration',
              subtitle: 'Manage Chromatic Aberration settings',
              value: state.isChromaticAberrationEnabled,
              onChanged: (val) => state.isChromaticAberrationEnabled = val,
            ),
            _buildDivider(context),
            _buildSwitchTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Depth Effect',
              subtitle: 'Manage Depth Effect settings',
              value: state.isDepthEffectEnabled,
              onChanged: (val) => state.isDepthEffectEnabled = val,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Appearance ──
          _buildSectionHeader(context, 'Appearance'),
          _buildTileGroup(context, [
            _buildActionTile(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Surface Tint',
              subtitle: 'Tint colour applied to the glass surface',
            ),
            _buildDivider(context),
            _buildActionTile(
              context: context,
              icon: Icons.tune_rounded,
              title: 'Surface Opacity',
              subtitle: 'Opacity of the glass tint overlay for readability',
            ),
            _buildDivider(context),
            _buildActionTile(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Glass Text Colour',
              subtitle: 'Text colour used on glass surfaces',
            ),
          ]),
          const SizedBox(height: 24),

          // ── Per Component ──
          _buildSectionHeader(context, 'Per Component'),
          _buildTileGroup(context, [
            _buildSwitchTile(
              context: context,
              icon: Icons.music_note_rounded,
              title: 'Glass Player',
              subtitle: 'Manage Glass Player settings',
              value: state.isGlassPlayerEnabled,
              onChanged: (val) => state.isGlassPlayerEnabled = val,
            ),
            _buildDivider(context),
            _buildSwitchTile(
              context: context,
              icon: Icons.music_note_rounded,
              title: 'Glass Mini Player',
              subtitle: 'Manage Glass Mini Player settings',
              value: state.isGlassMiniPlayerEnabled,
              onChanged: (val) => state.isGlassMiniPlayerEnabled = val,
            ),
            _buildDivider(context),
            _buildSwitchTile(
              context: context,
              icon: Icons.horizontal_split_rounded,
              title: 'Glass Navigation Bar',
              subtitle: 'Manage Glass Navigation Bar settings',
              value: state.isGlassNavigationBarEnabled,
              onChanged: (val) => state.isGlassNavigationBarEnabled = val,
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary, // Replaced 0xFFA5B4FC
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTileGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, // Replaced 0xFF1E1F29
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      height: 1,
      thickness: 1,
      indent: 64, // past icon
      endIndent: 16,
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: subtitle != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    required BuildContext context,
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
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            activeTrackColor: Theme.of(context).colorScheme.primary, // Replaced 0xFF1E3A8A Bright blue
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
