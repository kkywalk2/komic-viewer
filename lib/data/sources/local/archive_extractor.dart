import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/file_utils.dart';
import '../../../core/utils/natural_sort.dart';
import '../../models/comic_page.dart';

class ArchiveExtractor {
  static ArchiveExtractor? _instance;

  ArchiveExtractor._();

  static ArchiveExtractor get instance {
    _instance ??= ArchiveExtractor._();
    return _instance!;
  }

  Future<String> _getCacheDirectory(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final comicsDir = Directory(p.join(cacheDir.path, 'comics', bookId));
    if (!await comicsDir.exists()) {
      await comicsDir.create(recursive: true);
    }
    return comicsDir.path;
  }

  Future<List<ComicPage>> extractArchive(String archivePath, String bookId) async {
    final file = File(archivePath);
    if (!await file.exists()) {
      throw Exception('Archive file not found: $archivePath');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final imageFiles = archive.files
        .where((f) => !f.isFile ? false : isImageFile(f.name))
        .toList();

    imageFiles.sortNatural((f) => f.name);

    final cacheDir = await _getCacheDirectory(bookId);
    final pages = <ComicPage>[];

    for (var i = 0; i < imageFiles.length; i++) {
      final archiveFile = imageFiles[i];
      final ext = p.extension(archiveFile.name).toLowerCase();
      final newFileName = '${i.toString().padLeft(4, '0')}$ext';
      final outputPath = p.join(cacheDir, newFileName);

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(archiveFile.content as List<int>);

      pages.add(ComicPage(
        index: i,
        path: outputPath,
        originalName: archiveFile.name,
      ));
    }

    return pages;
  }

  Future<ComicPage?> extractFirstPage(String archivePath, String bookId) async {
    final file = File(archivePath);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final imageFiles = archive.files
        .where((f) => !f.isFile ? false : isImageFile(f.name))
        .toList();

    if (imageFiles.isEmpty) {
      return null;
    }

    imageFiles.sortNatural((f) => f.name);

    final firstFile = imageFiles.first;
    final cacheDir = await _getCacheDirectory(bookId);
    final ext = p.extension(firstFile.name).toLowerCase();
    final outputPath = p.join(cacheDir, '0000$ext');

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(firstFile.content as List<int>);

    return ComicPage(
      index: 0,
      path: outputPath,
      originalName: firstFile.name,
    );
  }

  Future<int> getPageCount(String archivePath) async {
    final file = File(archivePath);
    if (!await file.exists()) {
      return 0;
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    return archive.files
        .where((f) => !f.isFile ? false : isImageFile(f.name))
        .length;
  }

  Future<void> clearCache(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final bookCacheDir = Directory(p.join(cacheDir.path, 'comics', bookId));
    if (await bookCacheDir.exists()) {
      await bookCacheDir.delete(recursive: true);
    }
  }

  Future<bool> isCached(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final bookCacheDir = Directory(p.join(cacheDir.path, 'comics', bookId));
    return await bookCacheDir.exists();
  }

  Future<List<ComicPage>> loadFromCache(String bookId) async {
    final cacheDir = await getApplicationCacheDirectory();
    final bookCacheDir = Directory(p.join(cacheDir.path, 'comics', bookId));

    if (!await bookCacheDir.exists()) {
      return [];
    }

    final files = await bookCacheDir.list().toList();
    final imageFiles = files
        .whereType<File>()
        .where((f) => isImageFile(f.path))
        .toList();

    imageFiles.sort((a, b) => naturalCompare(
      p.basename(a.path),
      p.basename(b.path),
    ));

    return imageFiles.asMap().entries.map((entry) {
      return ComicPage(
        index: entry.key,
        path: entry.value.path,
        originalName: p.basename(entry.value.path),
      );
    }).toList();
  }
}
