import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../models/track_model.dart';
import '../services/playback_controller.dart';
import '../state/app_state.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';

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

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkColor,
              HSLColor.fromColor(baseColor).withLightness(0.08).toColor(),
              scaffoldBg,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ── Top Bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
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
                              color: const Color(0xFF111111), // Vinyl black
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                                // Inner highlight for vinyl grooves
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  blurRadius: 2,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Grooves
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(52),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
                                  ),
                                ),
                                // Album Art Label
                                ClipOval(
                                  child: SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: AlbumArtTile(
                                      emoji: track.albumArt,
                                      colorSeed: track.colorSeed,
                                      imageUrl: track.imageUrl,
                                      size: 140,
                                      borderRadius: 0,
                                    ),
                                  ),
                                ),
                                // Spindle Hole
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: scaffoldBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.5), width: 2),
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
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
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
                      progressBarColor: Colors.white,
                      baseBarColor: Colors.white.withValues(alpha: 0.2),
                      bufferedBarColor: Colors.white.withValues(alpha: 0.2),
                      thumbColor: Colors.white,
                      barHeight: 4.0,
                      thumbRadius: 6.0,
                      timeLabelTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
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
                          icon: Icon(Icons.shuffle, color: Colors.white.withValues(alpha: 0.7)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                          onPressed: () => state.skipPrevious(0),
                        ),
                        GestureDetector(
                          onTap: () => state.togglePlayPause(),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                          onPressed: () => state.skipNext(0),
                        ),
                        IconButton(
                          icon: Icon(Icons.repeat, color: Colors.white.withValues(alpha: 0.7)),
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
                    IconButton(
                      icon: Icon(Icons.devices, color: Colors.white.withValues(alpha: 0.5)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white.withValues(alpha: 0.5)),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
