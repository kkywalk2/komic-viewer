import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/hash_utils.dart';
import '../data/models/comic_book.dart';
import '../data/models/server_config.dart';
import '../data/models/webdav_item.dart';
import '../data/sources/local/database_helper.dart';
import '../data/sources/remote/webdav_source.dart';

class DownloadManager {
  static DownloadManager? _instance;
  final _uuid = const Uuid();
  bool _isCancelled = false;

  DownloadManager._();

  static DownloadManager get instance {
    _instance ??= DownloadManager._();
    return _instance!;
  }

  void cancelCurrentDownload() {
    _isCancelled = true;
  }

  Future<String> downloadAndCache({
    required ServerConfig server,
    required WebDavItem item,
    required void Function(int received, int total) onProgress,
  }) async {
    _isCancelled = false;

    final cacheDir = await getApplicationCacheDirectory();
    final downloadDir = Directory(p.join(cacheDir.path, 'downloads'));
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final bookId = generateBookId(ComicSource.webdav, server.id, item.path);
    final ext = p.extension(item.name);
    final localPath = p.join(downloadDir.path, '$bookId$ext');

    // Check if already cached
    final localFile = File(localPath);
    if (await localFile.exists()) {
      return localPath;
    }

    // Download
    final webdavSource = WebDavSource(server);
    await webdavSource.downloadFile(
      remotePath: item.path,
      localPath: localPath,
      onProgress: (received, total) {
        if (_isCancelled) {
          throw Exception('Download cancelled');
        }
        onProgress(received, total);
      },
    );

    // Save to file_cache table
    await _saveCacheMetadata(
      bookId: bookId,
      remotePath: item.path,
      localPath: localPath,
      fileSize: item.size,
    );

    return localPath;
  }

  Future<void> _saveCacheMetadata({
    required String bookId,
    required String remotePath,
    required String localPath,
    required int fileSize,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Check if entry exists
    final existing = await db.query(
      'file_cache',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );

    if (existing.isEmpty) {
      await db.insert('file_cache', {
        'id': _uuid.v4(),
        'book_id': bookId,
        'remote_path': remotePath,
        'local_path': localPath,
        'file_size': fileSize,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.update(
        'file_cache',
        {
          'local_path': localPath,
          'downloaded_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    }
  }

  Future<String?> getCachedPath(String bookId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'file_cache',
      where: 'book_id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final localPath = results.first['local_path'] as String;
    if (await File(localPath).exists()) {
      return localPath;
    }
    return null;
  }

  Future<void> clearCache() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('file_cache');

    for (final row in results) {
      final localPath = row['local_path'] as String;
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await db.delete('file_cache');
  }
}
