import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../models/comic_book.dart';
import '../models/reading_progress.dart';
import '../sources/local/database_helper.dart';
import '../../services/app_path_service.dart';
import '../../services/download_manager.dart';
import '../../services/thumbnail_service.dart';

class ReadingProgressRepository {
  static ReadingProgressRepository? _instance;
  final _uuid = const Uuid();
  final _pathService = AppPathService.instance;

  ReadingProgressRepository._();

  static ReadingProgressRepository get instance {
    _instance ??= ReadingProgressRepository._();
    return _instance!;
  }

  Future<ReadingProgress?> getByBookId(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'reading_progress',
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return _hydrateProgress(ReadingProgress.fromMap(results.first));
  }

  Future<List<ReadingProgress>> getRecentProgress({int limit = 10}) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'reading_progress',
      orderBy: 'last_read_at DESC',
      limit: limit,
    );

    final seenIdentityKeys = <String>{};
    final progressList = <ReadingProgress>[];
    for (final result in results) {
      final identityKey = _storedIdentityKey(
        source: result['source'] as String,
        serverId: result['server_id'] as String?,
        filePath: result['file_path'] as String,
      );
      if (!seenIdentityKeys.add(identityKey)) {
        await db.delete(
          'reading_progress',
          where: 'id = ?',
          whereArgs: [result['id']],
        );
        continue;
      }

      final progress = ReadingProgress.fromMap(result);
      final hydrated = await _hydrateProgress(progress);
      if (hydrated != null) {
        progressList.add(hydrated);
      }
    }

    return progressList;
  }

  Future<ReadingProgress> saveProgress({
    required ComicBook book,
    required int currentPage,
    required int totalPages,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final existing = await _getExistingProgressForBook(book);
    final isFinished = currentPage >= totalPages - 1;

    if (existing != null) {
      final updated = existing.copyWith(
        bookId: book.id,
        title: book.title,
        currentPage: currentPage,
        totalPages: totalPages,
        isFinished: isFinished,
        lastReadAt: now,
        source: book.source,
        serverId: book.serverId,
        filePath: book.path,
        coverPath: book.coverPath,
        localCachePath: book.localCachePath ?? existing.localCachePath,
      );
      final persistedUpdated = await _persistProgressPaths(updated);

      await db.update(
        'reading_progress',
        persistedUpdated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );

      return updated;
    }

    final progress = ReadingProgress(
      id: _uuid.v4(),
      bookId: book.id,
      title: book.title,
      coverPath: book.coverPath,
      source: book.source,
      serverId: book.serverId,
      filePath: book.path,
      localCachePath: book.localCachePath,
      currentPage: currentPage,
      totalPages: totalPages,
      isFinished: isFinished,
      lastReadAt: now,
      createdAt: now,
    );
    final persistedProgress = await _persistProgressPaths(progress);

    await db.insert('reading_progress', persistedProgress.toMap());
    return progress;
  }

  Future<void> deleteProgress(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('reading_progress', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByBookId(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'reading_progress',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('reading_progress');
  }

  Future<List<ReadingProgress>> getContinueReading() async {
    return getRecentProgress(limit: AppConstants.maxRecentBooks);
  }

  Future<ReadingProgress?> _getExistingProgressForBook(ComicBook book) async {
    final byId = await getByBookId(book.id);
    if (byId != null) {
      return byId;
    }

    final db = await DatabaseHelper.instance.database;
    final storedFilePath = await _storedFilePathForBook(book);
    if (storedFilePath == null) {
      return null;
    }

    late final List<Map<String, Object?>> results;
    if (book.serverId == null) {
      results = await db.query(
        'reading_progress',
        where: 'source = ? AND server_id IS NULL AND file_path = ?',
        whereArgs: [book.source.name, storedFilePath],
        orderBy: 'last_read_at DESC',
      );
    } else {
      results = await db.query(
        'reading_progress',
        where: 'source = ? AND server_id = ? AND file_path = ?',
        whereArgs: [book.source.name, book.serverId, storedFilePath],
        orderBy: 'last_read_at DESC',
      );
    }

    if (results.isEmpty) {
      return null;
    }

    for (final duplicate in results.skip(1)) {
      await db.delete(
        'reading_progress',
        where: 'id = ?',
        whereArgs: [duplicate['id']],
      );
    }

    return _hydrateProgress(ReadingProgress.fromMap(results.first));
  }

  Future<ReadingProgress?> _hydrateProgress(ReadingProgress progress) async {
    final db = await DatabaseHelper.instance.database;
    var resolvedProgress = progress;
    var didChange = false;

    final resolvedFilePath = await _resolveFilePath(progress);
    if (resolvedFilePath == null) {
      await db.delete(
        'reading_progress',
        where: 'id = ?',
        whereArgs: [progress.id],
      );
      return null;
    }

    var coverPath = await _pathService.resolveManagedPath(progress.coverPath);
    if (coverPath == null || !await File(coverPath).exists()) {
      final resolvedCoverPath = await ThumbnailService.instance
          .getThumbnailPath(progress.bookId);
      if (resolvedCoverPath != coverPath) {
        coverPath = resolvedCoverPath;
        didChange = true;
      }
    }

    var localCachePath = await _pathService.resolveManagedPath(
      progress.localCachePath,
    );
    if (progress.source == ComicSource.webdav &&
        (localCachePath == null || !await File(localCachePath).exists())) {
      final resolvedLocalCachePath = await DownloadManager.instance
          .getCachedPath(progress.bookId);
      if (resolvedLocalCachePath != localCachePath) {
        localCachePath = resolvedLocalCachePath;
        didChange = true;
      }
    }

    if (progress.source == ComicSource.webdav && localCachePath == null) {
      await db.delete(
        'reading_progress',
        where: 'id = ?',
        whereArgs: [progress.id],
      );
      return null;
    }

    if (didChange) {
      resolvedProgress = progress.copyWith(
        filePath: resolvedFilePath,
        coverPath: coverPath,
        localCachePath: localCachePath,
      );
      await db.update(
        'reading_progress',
        (await _persistProgressPaths(resolvedProgress)).toMap(),
        where: 'id = ?',
        whereArgs: [progress.id],
      );
    } else if (resolvedFilePath != progress.filePath ||
        coverPath != progress.coverPath ||
        localCachePath != progress.localCachePath) {
      resolvedProgress = progress.copyWith(
        filePath: resolvedFilePath,
        coverPath: coverPath,
        localCachePath: localCachePath,
      );
    }

    return resolvedProgress;
  }

  Future<ReadingProgress> _persistProgressPaths(
    ReadingProgress progress,
  ) async {
    final persistedFilePath = await _storedFilePathForProgress(progress);
    if (persistedFilePath == null) {
      throw Exception('읽기 기록 경로를 저장할 수 없습니다.');
    }

    return progress.copyWith(
      filePath: persistedFilePath,
      coverPath: await _pathService.toManagedPath(progress.coverPath),
      localCachePath: await _pathService.toManagedPath(progress.localCachePath),
    );
  }

  Future<String?> _resolveFilePath(ReadingProgress progress) async {
    if (progress.source == ComicSource.local) {
      final resolvedPath = await _pathService.resolveManagedPath(
        progress.filePath,
      );
      if (resolvedPath != null && await File(resolvedPath).exists()) {
        return resolvedPath;
      }
      return null;
    }

    return progress.filePath;
  }

  Future<String?> _storedFilePathForBook(ComicBook book) async {
    if (book.source == ComicSource.local) {
      return _pathService.toManagedPath(book.path);
    }

    return book.path;
  }

  Future<String?> _storedFilePathForProgress(ReadingProgress progress) async {
    if (progress.source == ComicSource.local) {
      return _pathService.toManagedPath(progress.filePath);
    }

    return progress.filePath;
  }

  String _storedIdentityKey({
    required String source,
    required String? serverId,
    required String filePath,
  }) {
    return '$source|${serverId ?? ''}|$filePath';
  }
}
