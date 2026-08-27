import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../services/spotify_metadata_service.dart';
import '../services/youtube_search_service.dart';
import '../services/recommendation_engine.dart';
import '../state/app_state.dart';
import '../theme/neko_theme.dart';
import '../widgets/playlist_row.dart';
import '../widgets/profile_bottom_sheet.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/track_bottom_sheet.dart';
import 'browse_all_screen.dart';

/// Main dashboard / home screen matching the minimalist redesign.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SpotifyMetadataService _spotifyService;

  List<TrackModel>? recentTracks;
  List<TrackModel>? recommendedTracks;
  List<Map<String, dynamic>> _homeSections = [];
  bool _isLoading = true;
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
    _loadDashboardData();
  }

  // Fallback section removed, handled by RecommendationEngine now

  Future<void> _loadDashboardData() async {
    _spotifyService.clearCache();
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        recentTracks = null;
        recommendedTracks = null;
        _homeSections = [];
      });
    }

    final state = AppStateProvider.of(context);
    
    try {
      if (state.pluginManager.isPluginActive && state.useSpotifyRecommendations) {
        final results = await Future.wait([
          _spotifyService.getNewReleases(),
          _spotifyService.getRecommendations(),
          _spotifyService.getHomeSections(),
        ]);
        
        if (mounted) {
          setState(() {
            recentTracks = results[0] as List<TrackModel>?;
            recommendedTracks = results[1] as List<TrackModel>?;
            _homeSections = results[2] as List<Map<String, dynamic>>;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to generic recommendations using YouTube
        final ytService = YouTubeSearchService();
        final sharedPrefs = await SharedPreferences.getInstance();
        final recEngine = RecommendationEngine(sharedPrefs, ytService);
        
        final results = await Future.wait<dynamic>([
          recEngine.getHeroTracks(state.recentlyListened),
          recEngine.getRecommendedTracks(state.recentlyListened),
          recEngine.getPersonalizedSections(state.recentlyListened),
        ]);
        
        if (mounted) {
          setState(() {
            recentTracks = results[0] as List<TrackModel>?;
            recommendedTracks = results[1] as List<TrackModel>?;
            _homeSections = results[2] as List<Map<String, dynamic>>;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      // Fallback to generic recommendations using YouTube if Spotify fails
      try {
        final ytService = YouTubeSearchService();
        final sharedPrefs = await SharedPreferences.getInstance();
        final recEngine = RecommendationEngine(sharedPrefs, ytService);
        
        final results = await Future.wait<dynamic>([
          recEngine.getHeroTracks(state.recentlyListened),
          recEngine.getRecommendedTracks(state.recentlyListened),
          recEngine.getPersonalizedSections(state.recentlyListened),
        ]);
        
        if (mounted) {
          setState(() {
            recentTracks = results[0] as List<TrackModel>?;
            recommendedTracks = results[1] as List<TrackModel>?;
            _homeSections = results[2] as List<Map<String, dynamic>>;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            recentTracks = [];
            recommendedTracks = [];
            _homeSections = [];
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isPluginActive = state.pluginManager.isPluginActive && state.useSpotifyRecommendations;
    
    if (isPluginActive && !_pluginLoaded) {
      _pluginLoaded = true;
      _loadDashboardData();
    } else if (!isPluginActive && _pluginLoaded) {
      _pluginLoaded = false;
      _homeSections = [];
      recentTracks = null;
      recommendedTracks = null;
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: NekoColors.accent,
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(child: _buildHeader(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Loading Skeleton ──
            if (_isLoading || state.pluginManager.isBootstrapping)
              const SliverToBoxAdapter(child: _HomeScreenSkeleton())
            else if ((recentTracks == null || recentTracks!.isEmpty) && 
                     (recommendedTracks == null || recommendedTracks!.isEmpty) && 
                     _homeSections.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Unable to load content', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Check your internet connection and try again.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        style: ElevatedButton.styleFrom(backgroundColor: NekoColors.accent, foregroundColor: Colors.white),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ── Hero Carousel ──
              if (recentTracks != null && recentTracks!.isNotEmpty) ...[
                SliverToBoxAdapter(child: _HeroCarouselWidget(tracks: recentTracks!.take(5).toList())),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],

              // ── Recommended Section ──
              if (recommendedTracks != null && recommendedTracks!.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      state.useSpotifyRecommendations 
                          ? 'Recommended for Today' 
                          : 'Based on your listening',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildAlbumsGrid(recommendedTracks!)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],

            // ── Dynamic Spotify Sections (Moved Downside) ──
            if (_homeSections.isNotEmpty)
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
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
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
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Large Brand title "Home"
          Text(
            'Home',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          // Single Avatar Button
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ProfileBottomSheet(),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/avatar/100/100'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsGrid(List<TrackModel> tracks) {
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;
    final titleColor = isAmoled ? Colors.white : const Color(0xFF2C2A28);
    final subtitleColor = isAmoled ? Colors.white70 : const Color(0xFF5B5651);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          mainAxisExtent: 160, 
        ),
        itemCount: tracks.length > 6 ? 6 : tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return GestureDetector(
            onTap: () => state.playTrack(track),
            onLongPress: () => TrackBottomSheet.show(context, track),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isAmoled)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                      ],
                    ),
                    child: AlbumArtTile(
                      emoji: track.albumArt,
                      colorSeed: track.colorSeed,
                      imageUrl: track.imageUrl,
                      size: double.infinity,
                      borderRadius: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  track.title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: titleColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCarouselWidget extends StatefulWidget {
  final List<TrackModel> tracks;
  const _HeroCarouselWidget({required this.tracks});

  @override
  State<_HeroCarouselWidget> createState() => _HeroCarouselWidgetState();
}

class _HeroCarouselWidgetState extends State<_HeroCarouselWidget> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.88 means the card takes up 88% width, leaving 12% for the peeking edges
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;
    
    final bgColor = isAmoled ? NekoColors.cardDark : const Color(0xFFBBC3A4);
    final titleColor = isAmoled ? Colors.white : const Color(0xFF2C2A28);
    final subtitleColor = isAmoled ? Colors.white70 : const Color(0xFF5B5651);
    final buttonBg = isAmoled ? NekoColors.accent : const Color(0xFF7A866A);
    final buttonText = Colors.white;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.tracks.length,
            itemBuilder: (context, index) {
              final track = widget.tracks[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(value) * 200,
                      width: double.infinity,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      if (!isAmoled)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                    ],
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => state.playTrack(track),
                    onLongPress: () => TrackBottomSheet.show(context, track),
                    child: Row(
                    children: [
                      // Album Art
                      Hero(
                        tag: 'hero-carousel-${track.spotifyId ?? track.title}-$index',
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: AlbumArtTile(
                            emoji: track.albumArt,
                            colorSeed: track.colorSeed,
                            imageUrl: track.imageUrl,
                            size: 130,
                            borderRadius: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              track.title,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              track.artist,
                              style: TextStyle(fontSize: 14, color: subtitleColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => state.playTrack(track),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonBg,
                                    foregroundColor: buttonText,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: const Text('Play', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => TrackBottomSheet(track: track),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.more_horiz, color: titleColor),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.tracks.length, (index) {
            final isActive = _currentIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive 
                    ? (isAmoled ? NekoColors.accent : const Color(0xFF7A866A)) 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

}

class _HomeScreenSkeleton extends StatefulWidget {
  const _HomeScreenSkeleton();

  @override
  _HomeScreenSkeletonState createState() => _HomeScreenSkeletonState();
}

class _HomeScreenSkeletonState extends State<_HomeScreenSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
    final titleColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1.0).animate(_controller),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Hero Carousel Skeleton
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 32),
          // Recommended Title Skeleton
          Container(
            height: 24,
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: titleColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          // Grid Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                mainAxisExtent: 160, 
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Sections Skeletons
          for (int i=0; i<2; i++) ...[
            Container(
              height: 24,
              width: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: titleColor, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (_, __) => Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }
}

