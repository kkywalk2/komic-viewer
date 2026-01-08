import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../data/models/comic_book.dart';
import '../data/repositories/comic_repository.dart';
import '../data/sources/local/database_helper.dart';

class ThumbnailService {
  static ThumbnailService? _instance;

  ThumbnailService._();

  static ThumbnailService get instance {
    _instance ??= ThumbnailService._();
    return _instance!;
  }

  Future<String> _getThumbnailDirectory() async {
    final cacheDir = await getApplicationCacheDirectory();
    final thumbnailDir = Directory(p.join(cacheDir.path, 'thumbnails'));
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return thumbnailDir.path;
  }

  Future<String?> getThumbnailPath(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'thumbnails',
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final path = results.first['path'] as String;
    if (await File(path).exists()) {
      return path;
    }
    return null;
  }

  Future<String?> generateThumbnail(ComicBook book) async {
    try {
      debugPrint('ThumbnailService: Starting thumbnail generation for ${book.id}');

      // Check if thumbnail already exists
      final existingPath = await getThumbnailPath(book.id);
      if (existingPath != null) {
        debugPrint('ThumbnailService: Thumbnail already exists at $existingPath');
        return existingPath;
      }

      // Extract first page
      debugPrint('ThumbnailService: Extracting cover from ${book.path}');
      final firstPage = await ComicRepository.instance.extractCover(book);
      if (firstPage == null) {
        debugPrint('ThumbnailService: extractCover returned null');
        return null;
      }
      debugPrint('ThumbnailService: First page extracted at ${firstPage.path}');

      final sourceFile = File(firstPage.path);
      if (!await sourceFile.exists()) {
        debugPrint('ThumbnailService: Source file does not exist: ${firstPage.path}');
        return null;
      }

      // Generate thumbnail
      final thumbnailDir = await _getThumbnailDirectory();
      final ext = p.extension(firstPage.path).toLowerCase();
      final thumbnailPath = p.join(thumbnailDir, '${book.id}$ext');
      debugPrint('ThumbnailService: Thumbnail path will be $thumbnailPath');

      // Resize image
      final sourceBytes = await sourceFile.readAsBytes();
      debugPrint('ThumbnailService: Source file size: ${sourceBytes.length} bytes');

      final resizedBytes = await _resizeImage(
        sourceBytes,
        AppConstants.thumbnailMaxWidth,
        AppConstants.thumbnailMaxHeight,
      );

      if (resizedBytes != null) {
        debugPrint('ThumbnailService: Resized image size: ${resizedBytes.length} bytes');
        await File(thumbnailPath).writeAsBytes(resizedBytes);
      } else {
        debugPrint('ThumbnailService: Resize failed, copying original');
        // Fallback: just copy the original
        await sourceFile.copy(thumbnailPath);
      }

      // Save to database
      await _saveThumbnailMetadata(book.id, thumbnailPath);
      debugPrint('ThumbnailService: Thumbnail saved successfully at $thumbnailPath');

      return thumbnailPath;
    } catch (e, stack) {
      debugPrint('ThumbnailService: Error generating thumbnail: $e');
      debugPrint('ThumbnailService: Stack trace: $stack');
      return null;
    }
  }

  Future<Uint8List?> _resizeImage(
    Uint8List bytes,
    int maxWidth,
    int maxHeight,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  Future<void> _saveThumbnailMetadata(String bookId, String path) async {
    final db = await DatabaseHelper.instance.database;

    final existing = await db.query(
      'thumbnails',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    if (existing.isEmpty) {
      await db.insert('thumbnails', {
        'book_id': bookId,
        'path': path,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.update(
        'thumbnails',
        {
          'path': path,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    }
  }

  Future<void> deleteThumbnail(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'thumbnails',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    if (results.isNotEmpty) {
      final path = results.first['path'] as String;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await db.delete('thumbnails', where: 'book_id = ?', whereArgs: [bookId]);
    }
  }

  Future<void> clearAllThumbnails() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('thumbnails');

    for (final row in results) {
      final path = row['path'] as String;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await db.delete('thumbnails');
  }

  Future<int> getThumbnailCacheSize() async {
    final thumbnailDir = await _getThumbnailDirectory();
    final dir = Directory(thumbnailDir);
    if (!await dir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
}
