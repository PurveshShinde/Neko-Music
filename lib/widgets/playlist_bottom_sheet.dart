import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../theme/neko_theme.dart';
import '../state/app_state.dart';
import 'neko_notification.dart';

class PlaylistBottomSheet extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback? onPin;

  const PlaylistBottomSheet({super.key, required this.playlist, this.onPin});

  static Future<void> show(BuildContext context, PlaylistModel playlist, {VoidCallback? onPin}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaylistBottomSheet(playlist: playlist, onPin: onPin),
    );
  }

  void _editTitle(BuildContext context) {
    Navigator.pop(context); // Close bottom sheet
    final controller = TextEditingController(text: playlist.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final state = AppStateProvider.of(context);
                final updated = PlaylistModel(
                  id: playlist.id,
                  title: controller.text.trim(),
                  subtitle: playlist.subtitle,
                  imageUrl: playlist.imageUrl,
                  colorSeed: playlist.colorSeed,
                  spotifyId: playlist.spotifyId,
                );
                state.localLibrary.updatePlaylist(updated);
                Navigator.pop(context);
                NekoNotification.show(context, 'Playlist renamed');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NekoColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Navigator.pop(context); // Close bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist?'),
        content: Text('Are you sure you want to delete "${playlist.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final state = AppStateProvider.of(context);
              state.localLibrary.deletePlaylist(playlist.id);
              Navigator.pop(context);
              NekoNotification.show(context, 'Playlist deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;

    return Container(
      padding: EdgeInsets.only(
        top: 24, 
        bottom: MediaQuery.of(context).viewPadding.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: isAmoled ? Colors.black : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: isAmoled ? Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Playlist info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(playlist.colorSeed).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    image: playlist.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(playlist.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: playlist.imageUrl == null
                      ? const Center(child: Icon(Icons.queue_music, size: 24))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        playlist.subtitle,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: textColor.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 8),

          // Actions
          if (playlist.spotifyId == null)
            _buildActionItem(
              context,
              icon: Icons.edit_outlined,
              title: 'Rename Playlist',
              onTap: () => _editTitle(context),
              textColor: textColor,
            ),
          _buildActionItem(
            context,
            icon: Icons.push_pin_outlined,
            title: 'Pin Playlist',
            onTap: () {
              Navigator.pop(context);
              if (onPin != null) {
                onPin!();
              } else {
                NekoNotification.show(context, 'Playlist pinned');
              }
            },
            textColor: textColor,
          ),
          if (playlist.spotifyId == null)
            _buildActionItem(
              context,
              icon: Icons.delete_outline,
              title: 'Delete Playlist',
              onTap: () => _confirmDelete(context),
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? textColor.withValues(alpha: 0.7), size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
