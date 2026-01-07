import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/preferences_provider.dart';
import 'shimmer_grid_item.dart';
import 'shimmer_list_item.dart';

class LibraryShimmer extends StatelessWidget {
  final LibraryViewMode viewMode;

  const LibraryShimmer({
    super.key,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == LibraryViewMode.list) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerListItem(),
          childCount: AppConstants.shimmerListItemCount,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerGridItem(),
          childCount: AppConstants.shimmerGridItemCount,
        ),
      ),
    );
  }
}
