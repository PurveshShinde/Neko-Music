import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import 'playlist_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAmoled = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      {'title': 'Pop', 'spotifyId': '37i9dQZF1DXcBWIGoYBM5M', 'color': 0xFFE13300, 'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80'},
      {'title': 'Hip-Hop', 'spotifyId': '37i9dQZF1DX0XUsuxWHRQd', 'color': 0xFF1E3264, 'image': 'https://images.unsplash.com/photo-1601643157091-ce5c665179ab?w=400&q=80'},
      {'title': 'Rock', 'spotifyId': '37i9dQZF1DWXRqgorJj26U', 'color': 0xFFE91429, 'image': 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=400&q=80'},
      {'title': 'Latin', 'spotifyId': '37i9dQZF1DX10zKzsJ2jva', 'color': 0xFFE1118C, 'image': 'https://images.unsplash.com/photo-1543627063-e38029c15858?w=400&q=80'},
      {'title': 'Dance/Electronic', 'spotifyId': '37i9dQZF1DX4dyzvuaRJ0n', 'color': 0xFFD84000, 'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80'},
      {'title': 'Indie', 'spotifyId': '37i9dQZF1DXdwmD5Q7Gxah', 'color': 0xFFE13300, 'image': 'https://images.unsplash.com/photo-1525362081669-2b476bb628c3?w=400&q=80'},
      {'title': 'Mood', 'spotifyId': '37i9dQZF1DX3rxVfibe1L0', 'color': 0xFF8D67AB, 'image': 'https://images.unsplash.com/photo-1458560871784-56d23406c091?w=400&q=80'},
      {'title': 'Workout', 'spotifyId': '37i9dQZF1DX76Wlfdnj7AP', 'color': 0xFF777777, 'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80'},
      {'title': 'K-Pop', 'spotifyId': '37i9dQZF1DX9tPFwDMOaN1', 'color': 0xFF148A08, 'image': 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=400&q=80'},
      {'title': 'Chill', 'spotifyId': '37i9dQZF1DWWQRwui0ExPn', 'color': 0xFF477D95, 'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80'},
      {'title': 'R&B', 'spotifyId': '37i9dQZF1DX4SBhb3jqBDD', 'color': 0xFFDC148C, 'image': 'https://images.unsplash.com/photo-1499415479124-43c32433a620?w=400&q=80'},
      {'title': 'Sleep', 'spotifyId': '37i9dQZF1DWZd79rJ6a7cD', 'color': 0xFF1E3264, 'image': 'https://images.unsplash.com/photo-1515894203077-94ada3902daf?w=400&q=80'},
    ];

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Browse',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  final color = Color(cat['color'] as int);
                  return GestureDetector(
                    onTap: () {
                      final playlist = PlaylistModel(
                        id: cat['spotifyId'] as String,
                        title: '${cat['title']} Mix',
                        subtitle: 'Curated for you',
                        colorSeed: cat['color'] as int,
                        spotifyId: cat['spotifyId'] as String,
                        imageUrl: cat['image'] as String,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistScreen(playlist: playlist),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!isAmoled)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Text(
                              cat['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            right: -15,
                            child: Transform.rotate(
                              angle: 0.4,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(-2, 2),
                                    )
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(cat['image'] as String),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom nav padding
        ],
      ),
    );
  }
}
