import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../widgets/track_bottom_sheet.dart';
import '../services/playback_controller.dart';
import '../state/app_state.dart';
import '../theme/neko_theme.dart';
import '../widgets/album_art_tile.dart';
import 'dart:ui';
import '../widgets/neko_notification.dart';
import '../services/download_service.dart';
import 'package:flutter/services.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    // Start animation if we are already playing on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPlaying = AppStateProvider.of(context).playbackController.isPlaying;
      if (isPlaying) {
        _rotationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _updateRotation(bool isPlaying) {
    if (isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final track = state.currentTrack;

    if (track == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No track playing", style: TextStyle(color: Colors.white))),
      );
    }

    final baseColor = Color(track.colorSeed);
    final darkColor = HSLColor.fromColor(baseColor).withLightness(0.2).toColor();
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    final isGlass = state.isGlassmorphismEnabled && state.isGlassPlayerEnabled;
    final isAmoled = state.isAmoledThemeEnabled;

    Widget backgroundWidget;
    
    // Always show the beautiful blurred mesh background based on album art (Spotify style)
    backgroundWidget = Stack(
      fit: StackFit.expand,
      children: [
        Container(color: baseColor),
        if (track.imageUrl != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Image.network(track.imageUrl!, fit: BoxFit.cover),
          ),
        Container(
          color: scaffoldBg.withValues(alpha: isAmoled ? 0.8 : 0.7),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: isGlass ? Colors.transparent : scaffoldBg,
        body: Stack(
          children: [
          backgroundWidget,
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ── Top Bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── Vinyl Record Art ──
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'album_art_${track.videoId}',
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * pi,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 60,
                                  offset: const Offset(0, 30),
                                ),
                                // Edge highlight
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              fit: StackFit.expand,
                              children: [
                                // Black Vinyl Background
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF111111), // Dark vinyl color
                                  ),
                                ),
                                // Inner grooves overlay for vinyl feel
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(36),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                                  ),
                                ),
                                // Album Art as the Inner Label
                                Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.45,
                                    heightFactor: 0.45,
                                    child: ClipOval(
                                      child: AlbumArtTile(
                                        emoji: track.albumArt,
                                        colorSeed: track.colorSeed,
                                        imageUrl: track.imageUrl,
                                        size: 200,
                                        borderRadius: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(64),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                                  ),
                                ),
                                // Spindle Hole
                                Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6), // Translucent inner ring
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: isGlass ? Colors.black.withValues(alpha: 0.5) : scaffoldBg,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Track Info ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        StatefulBuilder(
                          builder: (context, setInnerState) {
                            final isLiked = state.localLibrary.isLiked(track);
                            return IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? NekoColors.accent : Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () async {
                                final added = await state.localLibrary.toggleLikedSong(track);
                                setInnerState(() {});
                                if (context.mounted) {
                                  NekoNotification.show(
                                    context,
                                    added ? 'Added to Liked Songs' : 'Removed from Liked Songs',
                                    icon: added ? Icons.favorite : Icons.favorite_border_rounded,
                                  );
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () {
                            TrackBottomSheet.show(context, track);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Seek Bar ──
                StreamBuilder<DurationState>(
                  stream: state.playbackController.durationStateStream,
                  initialData: state.playbackController.currentDurationState,
                  builder: (context, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.progress ?? Duration.zero;
                    final buffered = durationState?.buffered ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;

                    return ProgressBar(
                      progress: progress,
                      buffered: buffered,
                      total: total,
                      progressBarColor: NekoColors.accent,
                      baseBarColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      bufferedBarColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      thumbColor: NekoColors.accent,
                      barHeight: 4.0,
                      thumbRadius: 6.0,
                      timeLabelTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      onSeek: (duration) {
                        state.playbackController.seek(duration);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Controls ──
                StreamBuilder<bool>(
                  stream: state.playbackController.playingStream,
                  initialData: state.playbackController.isPlaying,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    
                    // Side effect to update rotation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _updateRotation(isPlaying);
                    });
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shuffle, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous, color: Theme.of(context).colorScheme.onSurface, size: 40),
                          onPressed: () => state.skipPrevious(0),
                        ),
                        GestureDetector(
                          onTap: () => state.togglePlayPause(),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NekoColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: NekoColors.accent.withValues(alpha: 0.6),
                                  blurRadius: 32,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next, color: Theme.of(context).colorScheme.onSurface, size: 40),
                          onPressed: () => state.skipNext(0),
                        ),
                        IconButton(
                          icon: Icon(Icons.repeat, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          onPressed: () {},
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // ── Bottom actions ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: AppStateProvider.of(context).downloadService.downloadEvent,
                      builder: (context, _, __) {
                        final task = AppStateProvider.of(context).downloadService.getTask(track.id);
                        if (task != null) {
                          return ValueListenableBuilder<DownloadState>(
                            valueListenable: task.state,
                            builder: (context, state, __) {
                              if (state == DownloadState.downloading) {
                                return ValueListenableBuilder<double>(
                                  valueListenable: task.progress,
                                  builder: (context, progress, __) {
                                    return Container(
                                      width: 48,
                                      height: 48,
                                      padding: const EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        value: progress > 0 ? progress : null,
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                      ),
                                    );
                                  },
                                );
                              } else if (state == DownloadState.completed) {
                                return IconButton(
                                  icon: Icon(Icons.download_done, color: Theme.of(context).colorScheme.primary),
                                  onPressed: () {},
                                );
                              } else if (state == DownloadState.failed) {
                                return IconButton(
                                  icon: const Icon(Icons.error_outline, color: Colors.red),
                                  onPressed: () {},
                                );
                              }
                              return const SizedBox(width: 48, height: 48);
                            },
                          );
                        }
                        return IconButton(
                          icon: Icon(Icons.download_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          onPressed: () {
                            AppStateProvider.of(context).downloadService.downloadTrack(track);
                            NekoNotification.show(
                              context,
                              'Download started',
                              icon: Icons.download_rounded,
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.devices, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
              ],
            ),
          ),
          ),
        ],
      ),
    ));
  }
}
