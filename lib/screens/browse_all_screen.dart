import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../theme/slothify_theme.dart';
import 'playlist_screen.dart';

class BrowseAllScreen extends StatelessWidget {
  final String title;
  final List<PlaylistModel> playlists;

  const BrowseAllScreen({
    super.key,
    required this.title,
    required this.playlists,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(playlist: playlist),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: playlist.imageUrl != null
                        ? Image.network(
                            playlist.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Color(playlist.colorSeed),
                            child: const Center(
                              child: Icon(Icons.music_note, color: Colors.white, size: 48),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  playlist.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  playlist.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
