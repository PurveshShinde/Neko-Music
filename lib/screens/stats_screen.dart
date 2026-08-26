import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/skeleton_ui.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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
          'Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {}, // Just for visual matching
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Filter Row ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      // Continuous Dropdown Chip
                      PopupMenuButton<String>(
                        color: const Color(0xFF1E1F29),
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          _buildPopupMenuItem('Continuous'),
                          _buildPopupMenuItem('Weeks'),
                          _buildPopupMenuItem('Months'),
                          _buildPopupMenuItem('Years'),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2B3D), // Slightly lighter for active state
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Continuous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 12),
                      // 1 Week Chip
                      _buildChip('1 week', false),
                      const SizedBox(width: 8),
                      // 1 Month Chip
                      _buildChip('1 month', true),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Top Songs ──
              _buildSectionHeader('Top Songs'),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: _isLoading
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) => const SkeletonPlaylistCard(),
                        )
                      : const Center(
                          child: Text(
                            'No songs played yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Top Artists ──
              _buildSectionHeader('Top Artists'),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180, // Same height to accommodate text
                  child: _isLoading
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Skeleton.circular(width: 140, height: 140),
                                  SizedBox(height: 8),
                                  Skeleton(width: 100, height: 14),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No artists played yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Top Albums ──
              _buildSectionHeader('Top Albums'),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF90CAF9), // Light blue from screenshot
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title) {
    return PopupMenuItem(
      value: title,
      height: 48,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSongCard(TrackModel song, int rank) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AlbumArtTile(
                  emoji: song.albumArt,
                  colorSeed: song.colorSeed,
                  imageUrl: song.imageUrl,
                  size: 140,
                  borderRadius: 12,
                ),
                // Play Icon Overlay
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$rank. ${song.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '1 time • ${song.duration}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
