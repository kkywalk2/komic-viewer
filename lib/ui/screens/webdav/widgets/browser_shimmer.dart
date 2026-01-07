import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BrowserShimmer extends StatelessWidget {
  const BrowserShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return const _ShimmerListTile();
        },
      ),
    );
  }
}

class _ShimmerListTile extends StatelessWidget {
  const _ShimmerListTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Container(
        height: 16,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      subtitle: Container(
        height: 12,
        width: 60,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
