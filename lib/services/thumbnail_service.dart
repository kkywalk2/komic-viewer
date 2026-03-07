import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../data/models/comic_book.dart';
import '../data/repositories/comic_repository.dart';
import '../data/sources/local/database_helper.dart';
import 'app_path_service.dart';

class ThumbnailService {
  static ThumbnailService? _instance;
  static const String _thumbnailExtension = '.png';
  final _pathService = AppPathService.instance;

  ThumbnailService._();

  static ThumbnailService get instance {
    _instance ??= ThumbnailService._();
    return _instance!;
  }

  Future<String> _getThumbnailDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    final thumbnailDir = Directory(p.join(appDir.path, 'thumbnails'));
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

    final storedPath = results.first['path'] as String;
    final path = await _pathService.resolveManagedPath(storedPath);
    if (path != null && await _isValidThumbnailPath(path)) {
      return path;
    }
    await deleteThumbnail(bookId);
    return null;
  }

  Future<String?> resolveThumbnailPath(ComicBook book) async {
    final coverPath = await _pathService.resolveManagedPath(book.coverPath);
    if (coverPath != null && await _isValidImageFile(coverPath)) {
      return coverPath;
    }

    return getThumbnailPath(book.id);
  }

  Future<String?> generateThumbnail(ComicBook book) async {
    try {
      debugPrint(
        'ThumbnailService: Starting thumbnail generation for ${book.id}',
      );

      // Check if thumbnail already exists
      final existingPath = await getThumbnailPath(book.id);
      if (existingPath != null) {
        debugPrint(
          'ThumbnailService: Thumbnail already exists at $existingPath',
        );
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
        debugPrint(
          'ThumbnailService: Source file does not exist: ${firstPage.path}',
        );
        return null;
      }

      // Generate thumbnail
      final thumbnailDir = await _getThumbnailDirectory();
      final fallbackExt = p.extension(firstPage.path).toLowerCase();
      final pngThumbnailPath = p.join(
        thumbnailDir,
        '${book.id}$_thumbnailExtension',
      );
      debugPrint(
        'ThumbnailService: Preferred thumbnail path: $pngThumbnailPath',
      );

      // Resize image
      final sourceBytes = await sourceFile.readAsBytes();
      debugPrint(
        'ThumbnailService: Source file size: ${sourceBytes.length} bytes',
      );

      final resizedBytes = await _resizeImage(
        sourceBytes,
        AppConstants.thumbnailMaxWidth,
        AppConstants.thumbnailMaxHeight,
      );

      late final String thumbnailPath;
      if (resizedBytes != null) {
        debugPrint(
          'ThumbnailService: Resized image size: ${resizedBytes.length} bytes',
        );
        thumbnailPath = pngThumbnailPath;
        await File(thumbnailPath).writeAsBytes(resizedBytes);
      } else {
        debugPrint('ThumbnailService: Resize failed, copying original');
        // Fallback: just copy the original
        thumbnailPath = p.join(thumbnailDir, '${book.id}$fallbackExt');
        await sourceFile.copy(thumbnailPath);
      }

      if (!await _isValidImageFile(thumbnailPath)) {
        debugPrint(
          'ThumbnailService: Generated thumbnail is invalid: $thumbnailPath',
        );
        return null;
      }

      // Save to database
      await _saveThumbnailMetadata(book.id, thumbnailPath);
      debugPrint(
        'ThumbnailService: Thumbnail saved successfully at $thumbnailPath',
      );

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
    final managedPath = await _pathService.toManagedPath(path);
    if (managedPath == null) {
      throw Exception('썸네일 경로를 저장할 수 없습니다.');
    }

    final existing = await db.query(
      'thumbnails',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    if (existing.isEmpty) {
      await db.insert('thumbnails', {
        'book_id': bookId,
        'path': managedPath,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.update(
        'thumbnails',
        {
          'path': managedPath,
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
      final storedPath = results.first['path'] as String;
      final path = await _pathService.resolveManagedPath(storedPath);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await db.delete('thumbnails', where: 'book_id = ?', whereArgs: [bookId]);
    }
  }

  Future<void> clearAllThumbnails() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('thumbnails');

    for (final row in results) {
      final storedPath = row['path'] as String;
      final path = await _pathService.resolveManagedPath(storedPath);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
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

  Future<bool> _isValidThumbnailPath(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;

    try {
      final bytes = await file.readAsBytes();
      final actualExtension = _detectImageExtension(bytes);
      final pathExtension = p.extension(path).toLowerCase();

      if (actualExtension != null && actualExtension != pathExtension) {
        debugPrint(
          'ThumbnailService: Extension mismatch for $path '
          '(path: $pathExtension, actual: $actualExtension)',
        );
        return false;
      }

      return _canDecodeImage(bytes);
    } catch (e) {
      debugPrint('ThumbnailService: Invalid thumbnail path $path: $e');
      return false;
    }
  }

  Future<bool> _isValidImageFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;

    try {
      final bytes = await file.readAsBytes();
      return _canDecodeImage(bytes);
    } catch (e) {
      debugPrint('ThumbnailService: Invalid image file at $path: $e');
      return false;
    }
  }

  Future<bool> _canDecodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    frame.image.dispose();
    return true;
  }

  String? _detectImageExtension(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return '.png';
    }

    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }

    if (bytes.length >= 6) {
      final header = String.fromCharCodes(bytes.sublist(0, 6));
      if (header == 'GIF87a' || header == 'GIF89a') {
        return '.gif';
      }
    }

    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return '.webp';
    }

    return null;
  }
}
