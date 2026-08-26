import 'package:flutter/material.dart';
import 'package:hetu_script/values.dart';
import '../theme/slothify_theme.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../state/app_state.dart';
import 'playlist_screen.dart';

/// Library screen that shows user's saved playlists and tracks from Spotify.
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
      // Ensure token is valid before making API calls
      try {
        final isAuth = engine.eval("metadataPlugin.auth.isAuthenticated()") as bool;
        if (!isAuth) {
          debugPrint('[Library] Token expired, refreshing...');
          await engine.eval("metadataPlugin.auth.refreshCredentials()");
        }
      } catch (e) {
        debugPrint('[Library] Auth check/refresh failed: $e');
      }

      final metadataPlugin = engine.fetch("metadataPlugin") as HTInstance;
      final userEndpoint = metadataPlugin.memberGet("user") as HTInstance;

      // Fetch saved playlists
      final playlistsRaw = await userEndpoint.invoke(
        "savedPlaylists",
        namedArgs: {"limit": 50, "offset": 0},
      ) as Map;

      final playlistItems = playlistsRaw['items'] as List? ?? [];
      final playlists = playlistItems.where((p) => p != null && p is Map).map((p) {
        final pMap = p as Map;
        final images = pMap['images'] as List?;
        final imageUrl = (images != null && images.isNotEmpty)
            ? images[0]['url'] as String?
            : null;
        return PlaylistModel(
          title: pMap['name'] as String? ?? 'Playlist',
          subtitle: pMap['owner'] != null
              ? (pMap['owner'] as Map)['name'] as String? ?? 'Spotify'
              : pMap['description'] as String? ?? 'Spotify Playlist',
          imageUrl: imageUrl,
          colorSeed: 0xFF1DB954,
          spotifyId: pMap['id'] as String?,
        );
      }).toList();

      // Fetch saved tracks
      final tracksRaw = await userEndpoint.invoke(
        "savedTracks",
        namedArgs: {"limit": 30, "offset": 0},
      ) as Map;

      final trackItems = tracksRaw['items'] as List? ?? [];
      final tracks = trackItems.where((t) => t != null && t is Map).map((t) {
        final item = t as Map;
        final track = (item.containsKey('track') ? item['track'] : item) as Map;
        final durationMs = track['durationMs'] as int? ?? 0;
        final durationSecs = durationMs ~/ 1000;
        final duration = Duration(seconds: durationSecs)
            .toString()
            .split('.')
            .first
            .replaceFirst('0:', '');

        final artists = track['artists'] as List? ?? [];
        final artistName = artists.isNotEmpty
            ? (artists[0] as Map)['name'] as String? ?? 'Unknown'
            : 'Unknown';

        final album = track['album'] as Map?;
        final imageUrl = (album != null &&
                album['images'] != null &&
                (album['images'] as List).isNotEmpty)
            ? (album['images'] as List)[0]['url'] as String?
            : null;

        return TrackModel(
          title: track['name'] as String? ?? 'Unknown',
          artist: artistName,
          albumArt: '🎵',
          colorSeed: 0xFF1DB954,
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
      debugPrint('Error loading library: $e');
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
    final isPluginActive = state.pluginManager.isPluginActive;

    // Auto-load when plugin becomes active
    if (isPluginActive && _playlists == null && !_isLoading && _error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadLibrary());
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Text('Library',
                    style: Theme.of(context).textTheme.headlineLarge),
                const Spacer(),
                if (_playlists != null)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    onPressed: _loadLibrary,
                    style: IconButton.styleFrom(
                      backgroundColor: SlothifyColors.surfaceVariant,
                      shape: const CircleBorder(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: SlothifyColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: SlothifyColors.textTertiary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Playlists'),
              Tab(text: 'Liked Songs'),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !isPluginActive
                    ? _buildEmptyState(context, 'Connect a plugin to see your library')
                    : _error != null
                        ? _buildErrorState(context)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPlaylistsTab(context),
                              _buildTracksTab(context),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(BuildContext context) {
    if (_playlists == null || _playlists!.isEmpty) {
      return _buildEmptyState(context, 'No saved playlists found');
    }

    return RefreshIndicator(
      onRefresh: _loadLibrary,
      color: SlothifyColors.accent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _playlists!.length,
        itemBuilder: (context, index) {
          final playlist = _playlists![index];
          return _PlaylistTile(
            playlist: playlist,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTracksTab(BuildContext context) {
    if (_savedTracks == null || _savedTracks!.isEmpty) {
      return _buildEmptyState(context, 'No liked songs found');
    }

    return RefreshIndicator(
      onRefresh: _loadLibrary,
      color: SlothifyColors.accent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _savedTracks!.length,
        itemBuilder: (context, index) {
          final track = _savedTracks![index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: track.imageUrl != null
                  ? Image.network(track.imageUrl!,
                      width: 48, height: 48, fit: BoxFit.cover)
                  : Container(
                      width: 48,
                      height: 48,
                      color: Color(track.colorSeed),
                      child: Center(
                          child: Text(track.albumArt,
                              style: const TextStyle(fontSize: 20))),
                    ),
            ),
            title: Text(track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12)),
            trailing:
                const Icon(Icons.play_circle_fill, color: SlothifyColors.accent),
            onTap: () {
              final state = AppStateProvider.of(context);
              state.playQueue(_savedTracks!, startIndex: index).catchError((e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_rounded,
              size: 64,
              color: SlothifyColors.textTertiary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Failed to load library',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(_error ?? '',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadLibrary,
            style: ElevatedButton.styleFrom(
              backgroundColor: SlothifyColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.playlist, required this.onTap});
  final PlaylistModel playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: playlist.imageUrl != null
            ? Image.network(playlist.imageUrl!,
                width: 56, height: 56, fit: BoxFit.cover)
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(playlist.colorSeed),
                      Color(playlist.colorSeed).withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: Colors.white, size: 28),
              ),
      ),
      title: Text(playlist.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(playlist.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: SlothifyColors.textTertiary),
      onTap: onTap,
    );
  }
}
