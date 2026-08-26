import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../services/youtube_search_service.dart';
import '../state/app_state.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/skeleton_ui.dart';

import '../services/spotify_metadata_service.dart';

class PlaylistScreen extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final YouTubeSearchService _searchService = YouTubeSearchService();
  late final SpotifyMetadataService _spotifyService;
  List<TrackModel>? _tracks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spotifyService = SpotifyMetadataService(AppStateProvider.of(context).pluginManager);
      _loadTracks();
    });
  }

  Future<void> _loadTracks() async {
    try {
      List<TrackModel> tracks = [];
      if (widget.playlist.spotifyId != null) {
        tracks = await _spotifyService.getPlaylistTracks(widget.playlist.spotifyId!);
      } else if (widget.playlist.query != null) {
        tracks = await _searchService.searchTracks(widget.playlist.query!);
      }
      if (mounted) setState(() => _tracks = tracks);
    } catch (e) {
      if (mounted) setState(() => _tracks = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(widget.playlist.colorSeed);
    final isLoaded = _tracks != null;
    final state = AppStateProvider.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: baseColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    widget.playlist.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: baseColor),
                      // Gradient to fade into black
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.9),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      // The playlist cover image (if any) or just a big centered initial
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: widget.playlist.imageUrl != null 
                              ? Image.network(widget.playlist.imageUrl!, fit: BoxFit.cover)
                              : Container(
                                  color: HSLColor.fromColor(baseColor).withLightness(0.2).toColor(),
                                  child: Center(
                                    child: Text(
                                      widget.playlist.title[0],
                                      style: const TextStyle(fontSize: 80, color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  )
                ],
              ),
              
              // Actions row (Play, Shuffle, etc)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_border, color: Colors.white70, size: 28),
                      const SizedBox(width: 24),
                      const Icon(Icons.download_for_offline_outlined, color: Colors.white70, size: 28),
                      const Spacer(),
                      const Icon(Icons.shuffle, color: Colors.white70, size: 28),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        backgroundColor: SlothifyColors.accent,
                        onPressed: () {
                          if (isLoaded && _tracks!.isNotEmpty) {
                            state.playQueue(_tracks!, startIndex: 0);
                          }
                        },
                        child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // Tracks list
              if (!isLoaded)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonTrackTile(),
                    childCount: 8,
                  ),
                )
              else if (_tracks!.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No tracks found.', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = _tracks![index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: AlbumArtTile(
                          emoji: track.albumArt,
                          colorSeed: track.colorSeed,
                          imageUrl: track.imageUrl,
                          size: 56,
                          borderRadius: 4, // Spotify has relatively square/sharp edges for songs in lists
                        ),
                        title: Text(
                          track.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          track.artist,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.more_vert, color: Colors.white70),
                        onTap: () {
                          state.playQueue(_tracks!, startIndex: index);
                        },
                      );
                    },
                    childCount: _tracks!.length,
                  ),
                ),
              
              // Bottom padding for miniplayer
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          
          // Mini player
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(child: MiniPlayerWidget()),
          ),
        ],
      ),
    );
  }
}
