import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../screens/full_player_screen.dart';
import 'standard_mini_player.dart';
import 'glass_mini_player.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isGlass = state.isGlassmorphismEnabled && state.isGlassMiniPlayerEnabled;
    final track = state.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: state.playbackController.playingStream,
      initialData: state.playbackController.isPlaying,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => const FullPlayerScreen(),
                );
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300) {
                  // Swiped left - Next Track
                  state.skipNext(0);
                } else if (details.primaryVelocity! > 300) {
                  // Swiped right - Previous Track
                  state.skipPrevious(0);
                }
              },
              child: isGlass
                  ? GlassMiniPlayer(
                      key: ValueKey('glass_${track.spotifyId ?? track.title}'),
                      title: track.title,
                      artist: track.artist,
                      emoji: track.albumArt,
                      colorSeed: track.colorSeed,
                      imageUrl: track.imageUrl,
                      isPlaying: isPlaying,
                      onPlayPause: () => isPlaying ? state.playbackController.pause() : state.playbackController.play(),
                      onNext: () => state.skipNext(0),
                      onPrevious: () => state.skipPrevious(0),
                    )
                  : StandardMiniPlayer(
                      key: ValueKey('standard_${track.spotifyId ?? track.title}'),
                      title: track.title,
                      artist: track.artist,
                      emoji: track.albumArt,
                      colorSeed: track.colorSeed,
                      imageUrl: track.imageUrl,
                      isPlaying: isPlaying,
                      onPlayPause: () => state.togglePlayPause(),
                      onNext: () => state.skipNext(0),
                      onPrevious: () => state.skipPrevious(0),
                    ),
            ),
          ),
        );
      }
    );
  }
}

