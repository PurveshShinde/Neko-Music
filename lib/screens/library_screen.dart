import 'package:flutter/material.dart';
import 'package:hetu_script/values.dart';
import '../theme/neko_theme.dart';
import '../widgets/library_skeleton.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../state/app_state.dart';
import 'playlist_screen.dart';
import '../widgets/playlist_grid_cover.dart';
import '../widgets/playlist_bottom_sheet.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PlaylistModel>? _playlists;
  List<TrackModel>? _savedTracks;
  bool _isLoading = false;
  String? _error;
  bool _isGridView = true;
  final Set<String> _pinnedPlaylists = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLibrary());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    final state = AppStateProvider.of(context);
    if (!state.pluginManager.isPluginActive) return;
    final engine = state.pluginManager.getMetadataEngine();
    if (engine == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      try {
        final isAuth = engine.eval("metadataPlugin.auth.isAuthenticated()") as bool;
        if (!isAuth) {
          await engine.eval("metadataPlugin.auth.refreshCredentials()");
        }
      } catch (_) {}

      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final userEndpoint = metadataPlugin.memberGet("user") as HTInstance;

      final playlistsRaw = await userEndpoint.invoke("savedPlaylists", namedArgs: {"limit": 50, "offset": 0}) as Map;
      final playlistItems = playlistsRaw['items'] as List? ?? [];
      final playlists = playlistItems.where((p) => p != null && p is Map).map<PlaylistModel>((p) {
        final pMap = p as Map;
        final images = pMap['images'] as List?;
        final imageUrl = (images != null && images.isNotEmpty) ? images[0]['url'] as String? : null;
        return PlaylistModel(
          id: pMap['id'] as String? ?? pMap['name'] as String? ?? 'playlist',
          title: pMap['name'] as String? ?? 'Playlist',
          subtitle: pMap['owner'] != null ? (pMap['owner'] as Map)['name'] as String? ?? 'Spotify' : pMap['description'] as String? ?? 'Spotify Playlist',
          imageUrl: imageUrl,
          colorSeed: NekoColors.colorFromTitle(pMap['name'] as String? ?? 'Playlist').toARGB32(),
          spotifyId: pMap['id'] as String?,
        );
      }).toList();

      final tracksRaw = await userEndpoint.invoke("savedTracks", namedArgs: {"limit": 30, "offset": 0}) as Map;
      final trackItems = tracksRaw['items'] as List? ?? [];
      final tracks = trackItems.where((t) => t != null && t is Map).map<TrackModel>((t) {
        final item = t as Map;
        final track = (item.containsKey('track') ? item['track'] : item) as Map;
        final durationMs = track['durationMs'] as int? ?? 0;
        final duration = Duration(seconds: durationMs ~/ 1000).toString().split('.').first.replaceFirst('0:', '');
        final artists = track['artists'] as List? ?? [];
        final artistName = artists.isNotEmpty ? (artists[0] as Map)['name'] as String? ?? 'Unknown' : 'Unknown';
        final album = track['album'] as Map?;
        final imageUrl = (album != null && album['images'] != null && (album['images'] as List).isNotEmpty) ? (album['images'] as List)[0]['url'] as String? : null;
        return TrackModel(
          title: track['name'] as String? ?? 'Unknown',
          artist: artistName,
          albumArt: '🎵',
          colorSeed: NekoColors.colorFromTitle(track['name'] as String? ?? 'Unknown').toARGB32(),
          imageUrl: imageUrl,
          duration: duration,
          spotifyId: track['id'] as String?,
          isExplicit: track['explicit'] as bool? ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _playlists = playlists;
          _savedTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isAmoled = state.isAmoledThemeEnabled;
    final isPluginActive = state.pluginManager.isPluginActive;

    if (isPluginActive && _playlists == null && !_isLoading && _error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadLibrary());
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Text(
                  'Library',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, size: 24),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                if (_playlists != null)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    onPressed: _loadLibrary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: isAmoled ? NekoColors.accent : const Color(0xFF7A866A),
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Spotify'),
              Tab(text: 'Personal'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading && isPluginActive
                ? (_isGridView ? const GridSkeleton() : const LibrarySkeleton())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      !isPluginActive
                          ? _buildEmptyState(context, 'Connect a plugin to see your library')
                          : _error != null
                              ? _buildErrorState(context)
                              : _buildSpotifyTab(context, isAmoled),
                      _buildPersonalTab(context, isAmoled),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyTab(BuildContext context, bool isAmoled) {
    if (_playlists == null || _savedTracks == null) return const SizedBox.shrink();
    if (_playlists!.isEmpty && _savedTracks!.isEmpty) return _buildEmptyState(context, 'No Spotify items found');

    List<PlaylistModel> displayPlaylists = List.from(_playlists!);
    if (_savedTracks!.isNotEmpty) {
      displayPlaylists.insert(0, PlaylistModel(
        id: 'liked_songs',
        title: 'Liked Songs',
        subtitle: '${_savedTracks!.length} songs',
        colorSeed: 0xFFE91E63, // Pinkish for Liked Songs
        spotifyId: 'liked_songs',
      ));
    }

    displayPlaylists.sort((a, b) {
      final aPinned = _pinnedPlaylists.contains(a.spotifyId ?? a.title);
      final bPinned = _pinnedPlaylists.contains(b.spotifyId ?? b.title);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });

    return RefreshIndicator(
      onRefresh: _loadLibrary,
      color: NekoColors.accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          if (displayPlaylists.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'All Playlists',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _isGridView
                  ? _buildPlaylistGrid(displayPlaylists, isAmoled)
                  : _buildPlaylistList(displayPlaylists),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ],
      ),
    );
  }

  void _togglePin(String id) {
    setState(() {
      if (_pinnedPlaylists.contains(id)) {
        _pinnedPlaylists.remove(id);
      } else {
        _pinnedPlaylists.add(id);
      }
    });
  }

  Widget _buildLikedSongsCover({required double borderRadius}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF450AF5), // Deep purple-indigo
            Color(0xFF8E8CD8), // Soft periwinkle/blue
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.favorite, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context, bool isAmoled) {
    final state = AppStateProvider.of(context);
    final personalPlaylists = state.localLibrary.getPlaylists();

    if (personalPlaylists.isEmpty) {
      return _buildEmptyState(context, 'No personal playlists yet');
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {}); // Just rebuild to fetch from local storage again
      },
      color: NekoColors.accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'My Playlists',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isGridView
                ? _buildPlaylistGrid(personalPlaylists, isAmoled)
                : _buildPlaylistList(personalPlaylists),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(List<PlaylistModel> playlists, bool isAmoled) {
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
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          final playlistId = playlist.spotifyId ?? playlist.title;
          final isPinned = _pinnedPlaylists.contains(playlistId);
          final isLikedSongs = playlist.spotifyId == 'liked_songs';

          return GestureDetector(
            onLongPress: () {
              PlaylistBottomSheet.show(
                context,
                playlist,
                onPin: () => _togglePin(playlistId),
              ).then((_) => setState(() {}));
            },
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(
                    playlist: playlist,
                    preloadedTracks: isLikedSongs ? _savedTracks : null,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Column(
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
                        child: PlaylistGridCover(
                          playlist: playlist,
                          size: double.infinity,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      playlist.title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: titleColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      playlist.subtitle,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (isPinned)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: NekoColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistList(List<PlaylistModel> playlists) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        final playlistId = playlist.spotifyId ?? playlist.title;
        final isPinned = _pinnedPlaylists.contains(playlistId);
        final isLikedSongs = playlist.spotifyId == 'liked_songs';

        return GestureDetector(
          onLongPress: () {
            PlaylistBottomSheet.show(
              context,
              playlist,
              onPin: () => _togglePin(playlistId),
            ).then((_) => setState(() {}));
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                PlaylistGridCover(
                  playlist: playlist,
                  size: 56,
                  borderRadius: 10,
                ),
                if (isPinned)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: NekoColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
            title: Text(playlist.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
            subtitle: Text(playlist.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => PlaylistScreen(
                  playlist: playlist,
                  preloadedTracks: isLikedSongs ? _savedTracks : null,
                )
              )
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    if (_error != null && _error!.contains('401')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Login to Spotify', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Connect your account to view your library', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final state = AppStateProvider.of(context);
                state.currentNavIndex = 4; // Go to settings
              },
              style: ElevatedButton.styleFrom(backgroundColor: NekoColors.accent, foregroundColor: Colors.white),
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Failed to load library', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadLibrary,
            style: ElevatedButton.styleFrom(backgroundColor: NekoColors.accent, foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
