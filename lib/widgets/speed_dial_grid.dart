import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../state/app_state.dart';
import 'album_art_tile.dart';
import 'skeleton_ui.dart';

/// 3-column grid of song tiles (Speed Dial).
class SpeedDialGrid extends StatelessWidget {
  final List<TrackModel>? tracks;
  const SpeedDialGrid({super.key, this.tracks});

  @override
  Widget build(BuildContext context) {
    final tracksList = tracks;

    if (tracksList == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const Skeleton(width: double.infinity, height: double.infinity, borderRadius: 12);
          },
        ),
      );
    }

    if (tracksList.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0, // Square cards
        ),
        itemCount: tracksList.length,
        itemBuilder: (context, index) {
          return _SpeedDialTile(track: tracksList[index]);
        },
      ),
    );
  }
}

class _SpeedDialTile extends StatelessWidget {
  const _SpeedDialTile({required this.track});

  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final state = AppStateProvider.of(context);
        state.playTrack(track).catchError((e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing track: $e')),
          );
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
        children: [
          AlbumArtTile(
            emoji: track.albumArt,
            colorSeed: track.colorSeed,
            imageUrl: track.imageUrl,
            borderRadius: 12,
            size: double.infinity,
          ),
          // Gradient for text legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          // Text overlay
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Text(
              track.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ), // close Stack
      ), // close ClipRRect
    ); // close GestureDetector
  }
}
