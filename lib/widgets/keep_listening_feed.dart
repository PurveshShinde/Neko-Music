import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../theme/slothify_theme.dart';
import 'album_art_tile.dart';
import 'skeleton_ui.dart';

/// Horizontal scrollable list of recently played / "Keep Listening" tracks.
class KeepListeningFeed extends StatelessWidget {
  final List<TrackModel>? tracks;
  const KeepListeningFeed({super.key, this.tracks});

  @override
  Widget build(BuildContext context) {
    final trackList = tracks;

    if (trackList == null) {
      return SizedBox(
        height: 74,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return const SizedBox(width: 240, child: SkeletonSpeedDialCard());
          },
        ),
      );
    }

    if (trackList.isEmpty) return const SizedBox();

    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trackList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final track = trackList[index];
          return _KeepListeningTile(track: track);
        },
      ),
    );
  }
}

class _KeepListeningTile extends StatelessWidget {
  const _KeepListeningTile({required this.track});
  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SlothifyColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SlothifyColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          AlbumArtTile(
            emoji: track.albumArt,
            colorSeed: track.colorSeed,
            imageUrl: track.imageUrl,
            size: 52,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_filled_rounded,
            color: SlothifyColors.accent,
            size: 32,
          ),
        ],
      ),
    );
  }
}
