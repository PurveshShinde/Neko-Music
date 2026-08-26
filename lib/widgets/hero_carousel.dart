import 'package:flutter/material.dart';
import '../models/track_model.dart';
import 'album_art_tile.dart';
import 'skeleton_ui.dart';

/// Horizontally-scrollable hero carousel with large feature cards.
class HeroCarousel extends StatefulWidget {
  final List<TrackModel>? tracks;
  const HeroCarousel({super.key, this.tracks});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller;
  double _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.72, initialPage: 1);
    _controller.addListener(() {
      setState(() => _currentPage = _controller.page ?? 1);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.tracks;

    if (tracks == null) {
      return SizedBox(
        height: 240,
        child: PageView.builder(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final diff = (index - _currentPage).abs();
            final scale = (1 - diff * 0.12).clamp(0.85, 1.0);
            final opacity = (1 - diff * 0.3).clamp(0.5, 1.0);

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: const SkeletonHeroCard(),
                ),
              ),
            );
          },
        ),
      );
    }

    if (tracks.isEmpty) return const SizedBox();

    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final diff = (index - _currentPage).abs();
          final scale = (1 - diff * 0.12).clamp(0.85, 1.0);
          final opacity = (1 - diff * 0.3).clamp(0.5, 1.0);

          return TweenAnimationBuilder<double>(
            tween: Tween(end: scale),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            child: _HeroCard(track: tracks[index]),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.track});
  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    final color = Color(track.colorSeed);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background album art
            AlbumArtTile(
              emoji: track.albumArt,
              colorSeed: track.colorSeed,
              imageUrl: track.imageUrl,
              borderRadius: 20,
              size: double.infinity,
            ),
            // Gradient overlay for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: 18,
              right: 18,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.artist,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
