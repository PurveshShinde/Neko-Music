import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../services/youtube_search_service.dart';
import '../services/spotify_metadata_service.dart';
import '../state/app_state.dart';
import '../theme/slothify_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/speed_dial_grid.dart';
import '../widgets/playlist_row.dart';
import '../widgets/profile_bottom_sheet.dart';
import '../widgets/shimmer_box.dart';
import 'history_screen.dart';
import 'listen_together_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'browse_all_screen.dart';

/// Main dashboard / home screen with scrollable sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> moods = ['Workout', 'Commute', 'Sad', 'Focus', 'Sleep'];
  late SpotifyMetadataService _spotifyService;

  List<TrackModel>? heroTracks;
  List<TrackModel>? speedDialTracks;
  List<Map<String, dynamic>> _homeSections = [];
  bool _pluginLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spotifyService = SpotifyMetadataService(AppStateProvider.of(context).pluginManager);
      _checkPluginAndLoad();
    });
  }

  void _checkPluginAndLoad() {
    final state = AppStateProvider.of(context);
    if (state.pluginManager.isPluginActive) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    _spotifyService.clearCache();
    
    if (mounted) {
      setState(() {
        speedDialTracks = null;
        _homeSections = [];
      });
    }

    try {
      final results = await Future.wait([
        _spotifyService.getRecommendations(),
        _spotifyService.getHomeSections(),
      ]);
      
      if (mounted) {
        setState(() {
          speedDialTracks = results[0] as List<TrackModel>?;
          _homeSections = results[1] as List<Map<String, dynamic>>;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          speedDialTracks = [];
          _homeSections = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isPluginActive = state.pluginManager.isPluginActive;
    
    if (isPluginActive && !_pluginLoaded) {
      // The plugin just became active!
      _pluginLoaded = true;
      _loadDashboardData();
    } else if (!isPluginActive && _pluginLoaded) {
      // The plugin was removed
      _pluginLoaded = false;
      _homeSections = [];
      speedDialTracks = null;
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: SlothifyColors.accent,
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          // ── Header ──
          SliverToBoxAdapter(child: _buildHeader(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Hero Carousel or Plugin Warning ──
          if (state.pluginManager.isBootstrapping)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: SlothifyColors.accent),
                      const SizedBox(height: 16),
                      Text('Loading installed plugins...', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
              ),
            )
          else if (!_pluginLoaded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: SlothifyColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: SlothifyColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.extension_off_outlined, color: Colors.white54, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Plugin Required',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Slothify requires a metadata plugin to show recommendations and playlists.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SlothifyColors.accent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => _checkPluginAndLoad());
                        },
                        child: const Text('Go to Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],

          // ── Speed Dial Section ──
          if (speedDialTracks == null && _pluginLoaded) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Good afternoon'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildSpeedDialSkeleton()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ] else if (speedDialTracks != null && speedDialTracks!.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Good afternoon'), // Or dynamic greeting
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: SpeedDialGrid(tracks: speedDialTracks)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],

          // ── Dynamic Spotify Sections ──
          if (_homeSections.isEmpty && _pluginLoaded && speedDialTracks == null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSectionSkeleton(),
                childCount: 3,
              ),
            )
          else if (_homeSections.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = _homeSections[index];
                  final title = section['title'] as String;
                  final items = section['items'] as List<PlaylistModel>;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BrowseAllScreen(
                                      title: title,
                                      playlists: items,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Browse all',
                                style: TextStyle(
                                  color: SlothifyColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      PlaylistRow(playlists: items),
                      const SizedBox(height: 28),
                    ],
                  );
                },
                childCount: _homeSections.length,
              ),
            ),

          // Bottom padding so content doesn't sit under mini player.
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          // Brand title
          Text(
            'slothify',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          // Action buttons
          _HeaderIconButton(
            icon: Icons.history_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          _HeaderIconButton(
            icon: Icons.sync_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          _HeaderIconButton(
            icon: Icons.people_alt_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListenTogetherScreen()),
              );
            },
          ),
          _HeaderIconButton(
            icon: Icons.person_rounded,
            isAvatar: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ProfileBottomSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 56,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: SlothifyColors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const ShimmerBox(width: 56, height: 56, borderRadius: BorderRadius.horizontal(left: Radius.circular(4))),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 80, height: 12, borderRadius: BorderRadius.circular(2)),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 40, height: 10, borderRadius: BorderRadius.circular(2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerBox(width: 150, height: 24, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 140, height: 140, borderRadius: BorderRadius.all(Radius.circular(8))),
                  const SizedBox(height: 12),
                  ShimmerBox(width: 100, height: 14, borderRadius: BorderRadius.circular(2)),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 12, borderRadius: BorderRadius.circular(2)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isAvatar = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAvatar;

  @override
  Widget build(BuildContext context) {
    if (isAvatar) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/avatar/100/100'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: SlothifyColors.surfaceVariant,
        shape: const CircleBorder(),
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
