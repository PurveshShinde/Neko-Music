import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/skeleton_ui.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

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
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Filter Chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildChip('Local', true),
                      const SizedBox(width: 8),
                      _buildChip('Remote', false),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // ── Section Title ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Last week',
                    style: TextStyle(
                      color: Color(0xFF90CAF9), // Light blue from screenshot
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Track List ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F29), // Dark card background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isLoading
                        ? Column(
                            children: List.generate(
                              5,
                              (_) => const SkeletonTrackTile(),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: Text(
                                'No recently played tracks',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              
              // Padding for bottom
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          
          // Custom FAB placement
          Positioned(
            bottom: 80, // Above mini player
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1E3A8A), // Bright blue from screenshot
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {},
              child: const Icon(Icons.shuffle, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: MiniPlayerWidget(),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3F3F5A) : const Color(0xFF1E1F29),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, color: Colors.white, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTrackTile(TrackModel track) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: AlbumArtTile(
          emoji: track.albumArt,
          colorSeed: track.colorSeed,
          imageUrl: track.imageUrl,
          size: 48,
          borderRadius: 8,
        ),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (track.isExplicit) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              '${track.artist} • ${track.duration ?? "0:00"}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white70),
        onPressed: () {},
      ),
    );
  }
}
