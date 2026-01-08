import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/comic_book.dart';
import '../services/thumbnail_service.dart';

final thumbnailProvider =
    FutureProvider.family<String?, ComicBook>((ref, book) async {
  try {
    debugPrint('ThumbnailProvider: Loading thumbnail for ${book.title} (${book.id})');
    debugPrint('ThumbnailProvider: Book path: ${book.path}');

    // First check if thumbnail exists
    final existingPath = await ThumbnailService.instance.getThumbnailPath(book.id);
    if (existingPath != null) {
      debugPrint('ThumbnailProvider: Found existing thumbnail at $existingPath');
      return existingPath;
    }

    debugPrint('ThumbnailProvider: Generating new thumbnail...');
    // Generate thumbnail
    final result = await ThumbnailService.instance.generateThumbnail(book);
    debugPrint('ThumbnailProvider: Generated thumbnail result: $result');
    return result;
  } catch (e, stack) {
    debugPrint('ThumbnailProvider: Error loading thumbnail: $e');
    debugPrint('ThumbnailProvider: Stack trace: $stack');
    rethrow;
  }
});

final thumbnailCacheSizeProvider = FutureProvider<int>((ref) async {
  return await ThumbnailService.instance.getThumbnailCacheSize();
});
