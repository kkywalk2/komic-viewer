import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/preferences_provider.dart';

class LibraryHeader extends ConsumerWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final preferences = ref.watch(preferencesNotifierProvider);
    final notifier = ref.read(preferencesNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Text(
            '라이브러리',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Sort dropdown
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            initialValue: preferences.sortOption,
            onSelected: (option) {
              notifier.setSortOption(option);
            },
            itemBuilder: (context) {
              return SortOption.values.map((option) {
                return PopupMenuItem<SortOption>(
                  value: option,
                  child: Row(
                    children: [
                      if (option == preferences.sortOption)
                        const Icon(Icons.check, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(option.displayName),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          // View mode toggle
          IconButton(
            icon: Icon(
              preferences.viewMode == LibraryViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            tooltip: preferences.viewMode == LibraryViewMode.grid
                ? '리스트 보기'
                : '그리드 보기',
            onPressed: () {
              notifier.toggleViewMode();
            },
          ),
        ],
      ),
    );
  }
}
