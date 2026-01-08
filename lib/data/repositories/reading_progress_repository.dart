import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../models/comic_book.dart';
import '../models/reading_progress.dart';
import '../sources/local/database_helper.dart';

class ReadingProgressRepository {
  static ReadingProgressRepository? _instance;
  final _uuid = const Uuid();

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

    return ReadingProgress.fromMap(results.first);
  }

  Future<List<ReadingProgress>> getRecentProgress({int limit = 10}) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'reading_progress',
      orderBy: 'last_read_at DESC',
      limit: limit,
    );

    return results.map((map) => ReadingProgress.fromMap(map)).toList();
  }

  Future<ReadingProgress> saveProgress({
    required ComicBook book,
    required int currentPage,
    required int totalPages,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final existing = await getByBookId(book.id);
    final isFinished = currentPage >= totalPages - 1;

    if (existing != null) {
      final updated = existing.copyWith(
        currentPage: currentPage,
        totalPages: totalPages,
        isFinished: isFinished,
        lastReadAt: now,
        coverPath: book.coverPath,
        localCachePath: book.localCachePath ?? existing.localCachePath,
      );

      await db.update(
        'reading_progress',
        updated.toMap(),
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

    await db.insert('reading_progress', progress.toMap());
    return progress;
  }

  Future<void> deleteProgress(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'reading_progress',
      where: 'id = ?',
      whereArgs: [id],
    );
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
}
