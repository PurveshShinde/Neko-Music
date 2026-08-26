import 'package:flutter/material.dart';
import '../models/track_model.dart';
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
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              child: isGlass
                  ? GlassMiniPlayer(
                      key: const ValueKey('glass'),
                      title: track.title,
                      artist: track.artist,
                      emoji: track.albumArt,
                      colorSeed: track.colorSeed,
                      imageUrl: track.imageUrl,
                      isPlaying: isPlaying,
                      onPlayPause: () => state.togglePlayPause(),
                      onNext: () => state.skipNext(0),
                      onPrevious: () => state.skipPrevious(0),
                    )
                  : StandardMiniPlayer(
                      key: const ValueKey('standard'),
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

