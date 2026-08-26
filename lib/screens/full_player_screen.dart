import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../models/track_model.dart';
import '../services/playback_controller.dart';
import '../state/app_state.dart';
import '../theme/slothify_theme.dart';
import '../widgets/album_art_tile.dart';

class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({super.key});

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
    final darkColor = HSLColor.fromColor(baseColor).withLightness(0.15).toColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkColor,
              Colors.black,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Now Playing',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Album Art
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'album_art_${track.videoId}',
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AlbumArtTile(
                          emoji: track.albumArt,
                          colorSeed: track.colorSeed,
                          imageUrl: track.imageUrl,
                          size: double.infinity,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Track Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
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
                const SizedBox(height: 24),

                // Seek Bar
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
                      baseBarColor: Colors.white.withValues(alpha: 0.24),
                      bufferedBarColor: Colors.white.withValues(alpha: 0.24),
                      thumbColor: Colors.white,
                      barHeight: 4.0,
                      thumbRadius: 6.0,
                      timeLabelTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                      onSeek: (duration) {
                        state.playbackController.seek(duration);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Controls
                StreamBuilder<bool>(
                  stream: state.playbackController.playingStream,
                  initialData: state.playbackController.isPlaying,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle, color: Colors.white),
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
                              size: 40,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                          onPressed: () => state.skipNext(0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Bottom actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.devices, color: Colors.white70),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white70),
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
