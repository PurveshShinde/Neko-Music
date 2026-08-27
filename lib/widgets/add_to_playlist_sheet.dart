import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../theme/neko_theme.dart';
import '../state/app_state.dart';
import 'neko_notification.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final TrackModel track;

  const AddToPlaylistSheet({super.key, required this.track});

  static Future<void> show(BuildContext context, TrackModel track) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToPlaylistSheet(track: track),
    );
  }

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  final TextEditingController _createController = TextEditingController();

  @override
  void dispose() {
    _createController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: _createController,
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_createController.text.trim().isEmpty) return;
              
              final state = AppStateProvider.of(context);
              final playlist = await state.localLibrary.createPlaylist(
                _createController.text.trim(),
                'My Custom Playlist',
              );
              
              await state.localLibrary.addTrackToPlaylist(playlist.id, widget.track);
              
              if (mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close sheet
                NekoNotification.show(
                  context, 
                  'Added "${widget.track.title}" to ${playlist.title}',
                  icon: Icons.playlist_add_check_rounded,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NekoColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
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
    final playlists = state.localLibrary.getPlaylists();

    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to Playlist',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showCreateDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Divider(color: textColor.withValues(alpha: 0.1), height: 1),
          
          Expanded(
            child: playlists.isEmpty
                ? Center(
                    child: Text(
                      'No personal playlists yet.\\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(playlist.colorSeed).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.queue_music, size: 24),
                        ),
                        title: Text(playlist.title),
                        subtitle: Text('${state.localLibrary.getTracks(playlist.id).length} songs'),
                        onTap: () async {
                          await state.localLibrary.addTrackToPlaylist(playlist.id, widget.track);
                          if (mounted) {
                            Navigator.pop(context);
                            NekoNotification.show(
                              context, 
                              'Added to "${playlist.title}"',
                              icon: Icons.playlist_add_check_rounded,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
