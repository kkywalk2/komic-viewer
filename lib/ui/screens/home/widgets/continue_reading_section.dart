import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/comic_book.dart';
import '../../../../data/models/reading_progress.dart';
import '../../../../providers/thumbnail_provider.dart';

class ContinueReadingSection extends StatelessWidget {
  final List<ReadingProgress> progressList;

  const ContinueReadingSection({
    super.key,
    required this.progressList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '이어서 읽기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: progressList.length,
            itemBuilder: (context, index) {
              final progress = progressList[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < progressList.length - 1 ? 12 : 0,
                ),
                child: _ContinueReadingItem(progress: progress),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingItem extends ConsumerWidget {
  final ReadingProgress progress;

  const _ContinueReadingItem({required this.progress});

  ComicBook get _book => ComicBook(
        id: progress.bookId,
        title: progress.title,
        path: progress.filePath,
        source: progress.source,
        serverId: progress.serverId,
        localCachePath: progress.localCachePath,
        coverPath: progress.coverPath,
        addedAt: progress.createdAt,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressPercent = (progress.progressPercent * 100).toInt();
    final thumbnailAsync = ref.watch(thumbnailProvider(_book));

    return GestureDetector(
      onTap: () {
        context.push('/reader', extra: _book);
      },
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: thumbnailAsync.when(
                      data: (thumbnailPath) {
                        if (thumbnailPath != null) {
                          return Image.file(
                            File(thumbnailPath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                          );
                        }
                        return _buildPlaceholder(context);
                      },
                      loading: () => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => _buildPlaceholder(context),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.progressPercent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: const Radius.circular(8),
                              bottomRight: progress.progressPercent >= 1.0
                                  ? const Radius.circular(8)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$progressPercent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.book,
        size: 32,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
