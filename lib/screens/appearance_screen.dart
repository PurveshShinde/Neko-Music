import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'liquid_glass_screen.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _legacyIcon = false;
  bool _highRefreshRate = true;
  bool _dynamicTheme = false;

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
        title: Text(
          'Appearance',
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
          // ── Theme ──
          _buildSectionHeader('Theme'),
          _buildTileGroup([
            _buildSwitchTile(
              iconWidget: _buildLegacyIcon(),
              title: 'Legacy Icon',
              subtitle: 'Revert the app icon back to the original legacy design',
              value: _legacyIcon,
              onChanged: (val) => setState(() => _legacyIcon = val),
            ),
            _buildDivider(context),
            _buildActionTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Customize your app theme',
            ),
            _buildDivider(context),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'AMOLED Black Mode',
              subtitle: 'Use pure black for backgrounds to save battery on OLED screens',
              value: AppStateProvider.of(context).isAmoledThemeEnabled,
              onChanged: (val) {
                AppStateProvider.of(context).isAmoledThemeEnabled = val;
              },
            ),
            _buildDivider(context),
            _buildActionTile(
              icon: Icons.palette_outlined,
              title: 'Liquid Glass (Beta)',
              subtitle: 'Liquid Glass (Beta)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiquidGlassScreen()),
                );
              },
            ),
            _buildDivider(context),
            _buildSwitchTile(
              icon: Icons.speed_rounded,
              title: 'Enable high refresh rate',
              subtitle: 'Force the display to run at the highest supported refresh rate (e.g. 120Hz)',
              value: _highRefreshRate,
              onChanged: (val) => setState(() => _highRefreshRate = val),
            ),
            _buildDivider(context),
            _buildSwitchTile(
              icon: Icons.palette_outlined,
              title: 'Enable dynamic theme',
              subtitle: 'Enable or disable dynamic theme',
              value: _dynamicTheme,
              onChanged: (val) => setState(() => _dynamicTheme = val),
            ),
          ]),
          SizedBox(height: 24),

          // ── Mini-player ──
          _buildSectionHeader('Mini-player'),
          _buildTileGroup([
            _buildActionTile(
              icon: Icons.palette_outlined,
              title: 'Mini-player background style',
              subtitle: 'Follow theme',
            ),
          ]),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLegacyIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFFA5B4FC),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTileGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (subtitle == null) SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
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
            if (subtitle == null) SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    IconData? icon,
    Widget? iconWidget,
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
              children: [
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
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF1E3A8A), // Bright blue
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
