import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../../data/models/comic_book.dart';
import '../../../../providers/thumbnail_provider.dart';

class ComicListItem extends ConsumerWidget {
  final ComicBook comic;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ComicListItem({
    super.key,
    required this.comic,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final thumbnailAsync = ref.watch(thumbnailProvider(comic));

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 60,
                height: 80,
                child: thumbnailAsync.when(
                  data: (thumbnailPath) {
                    if (thumbnailPath != null) {
                      return Image.file(
                        File(thumbnailPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
                      );
                    }
                    return _buildPlaceholder(colorScheme);
                  },
                  loading: () => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => _buildPlaceholder(colorScheme),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildMetadata(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: colorScheme.outline,
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _buildMetadata() {
    final parts = <String>[];

    if (comic.pageCount > 0) {
      parts.add('${comic.pageCount}페이지');
    }

    if (comic.fileSize > 0) {
      parts.add(formatFileSize(comic.fileSize));
    }

    parts.add(_formatDate(comic.addedAt));

    return parts.join(' • ');
  }
}
