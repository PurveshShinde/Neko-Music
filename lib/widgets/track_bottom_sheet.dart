import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../theme/neko_theme.dart';
import 'add_to_playlist_sheet.dart';
import '../state/app_state.dart';
import 'neko_notification.dart';

class TrackBottomSheet extends StatelessWidget {
  final TrackModel track;

  const TrackBottomSheet({super.key, required this.track});

  static Future<void> show(BuildContext context, TrackModel track) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TrackBottomSheet(track: track),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;

    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
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

          // Track info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(track.colorSeed).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    image: track.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(track.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: track.imageUrl == null
                      ? Center(child: Text(track.albumArt, style: const TextStyle(fontSize: 24)))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
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
                        track.artist,
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
          
          const SizedBox(height: 24),
          Divider(color: textColor.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),

          // Actions
          _buildActionTile(
            context,
            icon: Icons.playlist_add_rounded,
            title: 'Add to Playlist',
            onTap: () {
              Navigator.pop(context);
              AddToPlaylistSheet.show(context, track);
            },
          ),
          StatefulBuilder(
            builder: (context, setInnerState) {
              final isLiked = state.localLibrary.isLiked(track);
              return _buildActionTile(
                context,
                icon: isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                title: isLiked ? 'Remove from Liked Songs' : 'Add to Liked Songs',
                iconColor: isLiked ? NekoColors.accent : null,
                onTap: () async {
                  final added = await state.localLibrary.toggleLikedSong(track);
                  if (context.mounted) {
                    Navigator.pop(context);
                    NekoNotification.show(
                      context,
                      added ? 'Added to Liked Songs' : 'Removed from Liked Songs',
                      icon: added ? Icons.favorite : Icons.favorite_border_rounded,
                    );
                  }
                },
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? textColor.withValues(alpha: 0.8), size: 26),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.9),
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
