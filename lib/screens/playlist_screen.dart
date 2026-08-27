import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/neko_notification.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../services/youtube_search_service.dart';
import '../state/app_state.dart';
import '../widgets/track_bottom_sheet.dart';
import '../theme/neko_theme.dart';
import '../widgets/album_art_tile.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/skeleton_ui.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/playlist_grid_cover.dart';
import '../services/spotify_metadata_service.dart';

class PlaylistScreen extends StatefulWidget {
  final PlaylistModel playlist;
  final List<TrackModel>? preloadedTracks;
  const PlaylistScreen({super.key, required this.playlist, this.preloadedTracks});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final YouTubeSearchService _searchService = YouTubeSearchService();
  late final SpotifyMetadataService _spotifyService;
  List<TrackModel>? _tracks;
  Color? _dynamicColor;

  late PlaylistModel _currentPlaylist;
  bool get _isLocalPlaylist => _currentPlaylist.spotifyId == null && _currentPlaylist.query == null;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spotifyService = SpotifyMetadataService(AppStateProvider.of(context).pluginManager);
      _loadTracks();
      _extractDominantColor();
    });
  }

  Future<void> _extractDominantColor() async {
    if (_currentPlaylist.imageUrl == null) return;
    try {
      final isNetwork = _currentPlaylist.imageUrl!.startsWith('http://') || _currentPlaylist.imageUrl!.startsWith('https://');
      final imageProvider = isNetwork ? NetworkImage(_currentPlaylist.imageUrl!) as ImageProvider : FileImage(File(_currentPlaylist.imageUrl!));
      final palette = await PaletteGenerator.fromImageProvider(imageProvider);
      if (palette.dominantColor != null && mounted) {
        setState(() {
          _dynamicColor = palette.dominantColor!.color;
        });
      }
    } catch (e) {
      debugPrint('Failed to extract color: $e');
    }
  }

  Future<void> _refreshTracks() async {
    if (!mounted) return;
    setState(() {
      _tracks = null;
    });
    await _loadTracks();
  }

  Future<void> _loadTracks() async {
    if (widget.preloadedTracks != null) {
      if (mounted) setState(() => _tracks = widget.preloadedTracks);
      return;
    }
    try {
      List<TrackModel> tracks = [];
      if (widget.playlist.spotifyId != null && widget.playlist.spotifyId != 'liked_songs' && widget.playlist.spotifyId != 'downloaded_songs') {
        tracks = widget.playlist.isAlbum
            ? await _spotifyService.getAlbumTracks(_currentPlaylist.spotifyId!)
            : await _spotifyService.getPlaylistTracks(_currentPlaylist.spotifyId!);
      } else if (_currentPlaylist.query != null) {
        final results = await _searchService.searchCategorized(_currentPlaylist.query!, 'songs');
        tracks = results.whereType<TrackModel>().toList();
      } else {
        // Local playlist
        final localLibrary = AppStateProvider.of(context).localLibrary;
        tracks = localLibrary.getTracks(_currentPlaylist.id);
      }
      if (mounted) {
        setState(() => _tracks = tracks);
        _resolveMissingDurations();
      }
    } catch (e) {
      if (mounted) setState(() => _tracks = []);
    }
  }

  Future<void> _pickImage() async {
    if (!_isLocalPlaylist) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        // Save image to persistent storage so it survives app restarts
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'playlist_cover_${_currentPlaylist.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        
        final updated = _currentPlaylist.copyWith(imageUrl: savedImage.path);
        await AppStateProvider.of(context).localLibrary.updatePlaylist(updated);
        setState(() {
          _currentPlaylist = updated;
        });
        _extractDominantColor();
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<void> _editTitle() async {
    if (!_isLocalPlaylist) return;
    final controller = TextEditingController(text: _currentPlaylist.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Edit Playlist Title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'New Title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != _currentPlaylist.title && mounted) {
      final updated = _currentPlaylist.copyWith(title: newTitle);
      await AppStateProvider.of(context).localLibrary.updatePlaylist(updated);
      setState(() {
        _currentPlaylist = updated;
      });
    }
  }

  Future<void> _resolveMissingDurations() async {
    if (_tracks == null) return;
    for (var i = 0; i < _tracks!.length; i++) {
      if (!mounted) break;
      final track = _tracks![i];
      if (track.duration == null || track.duration == '0:00' || track.duration == '00:00') {
        try {
          // Avoid overloading the API, just do a quick search
          final results = await _searchService.searchCategorized('${track.title} ${track.artist}', 'songs');
          if (results.isNotEmpty && mounted) {
            final firstTrack = results.whereType<TrackModel>().firstOrNull;
            if (firstTrack?.duration != null) {
              track.duration = firstTrack!.duration;
              if (mounted) setState(() {});
            }
          }
        } catch (_) {}
      }
    }
  }

  String _getTotalDuration() {
    if (_tracks == null || _tracks!.isEmpty) return "";
    int totalSeconds = 0;
    for (var track in _tracks!) {
      if (track.duration != null) {
        final parts = track.duration!.split(':');
        try {
          if (parts.length == 2) {
            totalSeconds += int.parse(parts[0]) * 60 + int.parse(parts[1]);
          } else if (parts.length == 3) {
            totalSeconds += int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
          }
        } catch (_) {}
      }
    }
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return "$hours hr $minutes min";
    return "$minutes min";
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _dynamicColor ?? Color(widget.playlist.colorSeed);
    final isLoaded = _tracks != null;
    final state = AppStateProvider.of(context);
    
    final isGlass = state.isGlassmorphismEnabled;
    final isAmoled = state.isAmoledThemeEnabled;
    
    // Theme 1: Light Vintage (#F9F6F0)
    // Theme 2: Clean AMOLED (#000000)
    // Theme 3: Liquid Glass (AMOLED base, blurred orb)
    final scaffoldBg = isAmoled ? NekoColors.amoledBackground : NekoColors.lightBackground;
    final textColor = isAmoled ? NekoColors.amoledTextPrimary : NekoColors.lightTextPrimary;
    final secondaryTextColor = isAmoled ? NekoColors.amoledTextSecondary : NekoColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isGlass ? Colors.transparent : scaffoldBg,
      body: Stack(
        children: [
          // Background rendering based on theme
          if (isGlass) ...[
            Container(color: NekoColors.amoledBackground), // Pure AMOLED base for glass
            // Massive blurred color orb
            Positioned(
              top: -100,
              left: -50,
              right: -50,
              height: 400,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ] else if (!isAmoled) ...[
            // Light vintage radial glow
            Container(color: NekoColors.lightBackground),
            Positioned(
              top: -150,
              left: 0,
              right: 0,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Pure AMOLED clean dark
            Container(color: NekoColors.amoledBackground),
          ],

          RefreshIndicator(
            onRefresh: _refreshTracks,
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                iconTheme: IconThemeData(color: textColor),
                actions: [
                  IconButton(
                    icon: Icon(Icons.more_vert, color: textColor),
                    onPressed: () {},
                  )
                ],
              ),
              
              // ── 1. Header (Artwork & Metadata) ──
              SliverToBoxAdapter(
                child: _buildHeader(context, baseColor, isAmoled, isGlass, textColor, secondaryTextColor),
              ),
              
              // ── 2. Action Bar ──
              SliverToBoxAdapter(
                child: _buildActionBar(context, baseColor, isAmoled, isGlass, isLoaded),
              ),

              // ── 3. Track List ──
              if (!isLoaded)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonTrackTile(),
                    childCount: 8,
                  ),
                )
              else if (_tracks!.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('No tracks found.', style: TextStyle(color: secondaryTextColor)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildTrackTile(context, _tracks![index], index, isAmoled, isGlass, textColor, secondaryTextColor);
                      },
                      childCount: _tracks!.length,
                    ),
                  ),
                ),
              
                // Bottom padding for miniplayer
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
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

  Widget _buildHeader(BuildContext context, Color baseColor, bool isAmoled, bool isGlass, Color textColor, Color secondaryColor) {
    Widget artwork;
    
    if (isGlass) {
      // Elevated glass-framed art
      artwork = LiquidGlassContainer(
        width: 220,
        height: 220,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(24),
        child: PlaylistGridCover(
          playlist: widget.playlist,
          size: 220,
          borderRadius: 24,
        ),
      );
    } else if (isAmoled) {
      // Clean AMOLED: Floating album card with glow
      artwork = Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PlaylistGridCover(
            playlist: _currentPlaylist,
            size: 220,
            borderRadius: 16,
          ),
        ),
      );
    } else {
      // Minimalist Light Vintage: Rounded rectangle (CD art)
      artwork = Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // CD shape
          border: Border.all(color: const Color(0xFFE5DFD5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              PlaylistGridCover(
                playlist: _currentPlaylist,
                size: 220,
                borderRadius: 110, // Full circle
              ),
              // Inner spindle ring
              Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                    color: NekoColors.lightBackground.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              artwork,
              if (_isLocalPlaylist)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: _isLocalPlaylist ? _editTitle : null,
                  child: Text(
                    _currentPlaylist.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (_isLocalPlaylist) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: secondaryColor,
                  onPressed: _editTitle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentPlaylist.subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "${_tracks?.length ?? 0} songs • ${_getTotalDuration()}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, Color baseColor, bool isAmoled, bool isGlass, bool isLoaded) {
    final state = AppStateProvider.of(context);
    final iconColor = isAmoled || isGlass ? NekoColors.amoledTextPrimary : NekoColors.lightTextPrimary;
    
    Widget playButton;
    if (isGlass) {
      playButton = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: baseColor,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
      );
    } else if (isAmoled) {
      playButton = Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
      );
    } else {
      // Warm terracotta / amber for light theme
      playButton = Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFC88A3E),
        ),
        child: const Icon(Icons.play_arrow, color: Color(0xFFF9F6F0), size: 32),
      );
    }

    final actionRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite_border, color: iconColor),
        const SizedBox(width: 24),
        IconButton(
          icon: Icon(Icons.download_for_offline_outlined, color: iconColor),
          onPressed: () {
            if (isLoaded && _tracks != null) {
              state.downloadService.downloadPlaylist(_currentPlaylist, _tracks!);
              NekoNotification.show(
                context,
                'Downloading playlist...',
                icon: Icons.download_rounded,
              );
            }
          },
        ),
        const SizedBox(width: 24),
        Icon(Icons.shuffle, color: iconColor),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: () {
            if (isLoaded && _tracks!.isNotEmpty) {
              state.playQueue(_tracks!, startIndex: 0);
            }
          },
          child: playButton,
        ),
      ],
    );

    if (isGlass) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
              child: actionRow,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: actionRow,
    );
  }

  Widget _buildTrackTile(BuildContext context, TrackModel track, int index, bool isAmoled, bool isGlass, Color textColor, Color secondaryColor) {
    final state = AppStateProvider.of(context);
    
    Widget tileContent = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: AlbumArtTile(
        emoji: track.albumArt,
        colorSeed: track.colorSeed,
        imageUrl: track.imageUrl,
        size: 48,
        borderRadius: 12,
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: secondaryColor.withValues(alpha: 0.8),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (track.duration != null && track.duration != '00:00' && track.duration != '0:00')
            Text(
              track.duration!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
            )
          else
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: secondaryColor.withValues(alpha: 0.5)),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              TrackBottomSheet.show(context, track);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.more_vert, color: secondaryColor, size: 20),
            ),
          ),
        ],
      ),
      onTap: () {
        state.playQueue(_tracks!, startIndex: index);
      },
      onLongPress: () {
        TrackBottomSheet.show(context, track);
      },
    );

    if (isGlass) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: tileContent,
            ),
          ),
        ),
      );
    } else if (isAmoled) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: tileContent,
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFECE6), width: 1),
        ),
        child: tileContent,
      );
    }
  }
}
