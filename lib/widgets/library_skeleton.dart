import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      itemCount: 8, // show 8 skeleton items
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const ShimmerBox(width: 56, height: 56, borderRadius: BorderRadius.all(Radius.circular(12))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 150, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: 100, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            ],
          ),
        );
      },
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // Adjust for card aspect ratio
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            SizedBox(height: 12),
            ShimmerBox(width: 100, height: 16),
            SizedBox(height: 8),
            ShimmerBox(width: 60, height: 12),
          ],
        );
      },
    );
  }
}
