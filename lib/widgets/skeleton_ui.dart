import 'package:flutter/material.dart';
import '../theme/neko_theme.dart';

class Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  const Skeleton.circular({
    super.key,
    required this.width,
    required this.height,
  })  : borderRadius = 0,
        shape = BoxShape.circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmoled = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isAmoled ? NekoColors.surfaceVariant : const Color(0xFFE5E0D5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specific Skeleton Layouts
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonTrackTile extends StatelessWidget {
  const SkeletonTrackTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Skeleton(width: 50, height: 50, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 150, height: 16),
                SizedBox(height: 8),
                Skeleton(width: 100, height: 14),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Skeleton.circular(width: 24, height: 24),
        ],
      ),
    );
  }
}

class SkeletonSpeedDialCard extends StatelessWidget {
  const SkeletonSpeedDialCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isAmoled = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isAmoled ? NekoColors.surfaceVariant : const Color(0xFFE5E0D5);

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Skeleton(
            width: 56,
            height: 56,
            borderRadius: 8,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Skeleton(width: double.infinity, height: 14),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class SkeletonPlaylistCard extends StatelessWidget {
  const SkeletonPlaylistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Skeleton(width: 140, height: 140, borderRadius: 12),
          SizedBox(height: 12),
          Skeleton(width: 120, height: 16),
          SizedBox(height: 8),
          Skeleton(width: 80, height: 14),
        ],
      ),
    );
  }
}

class SkeletonHeroCard extends StatelessWidget {
  const SkeletonHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      width: double.infinity,
      height: 240, // Match typical hero height
      borderRadius: 24,
    );
  }
}
