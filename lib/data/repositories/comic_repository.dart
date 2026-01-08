import 'dart:io';

import '../models/comic_book.dart';
import '../models/comic_page.dart';
import '../sources/local/archive_extractor.dart';
import '../sources/local/local_file_source.dart';
import '../../services/download_manager.dart';

class ComicRepository {
  static ComicRepository? _instance;

  final LocalFileSource _localFileSource;
  final ArchiveExtractor _archiveExtractor;

  ComicRepository._()
      : _localFileSource = LocalFileSource.instance,
        _archiveExtractor = ArchiveExtractor.instance;

  static ComicRepository get instance {
    _instance ??= ComicRepository._();
    return _instance!;
  }

  Future<ComicBook?> pickAndImportComic() async {
    final book = await _localFileSource.pickAndImportFile();
    if (book == null) return null;

    final pageCount = await _archiveExtractor.getPageCount(book.path);
    return book.copyWith(pageCount: pageCount);
  }

  Future<List<ComicBook>> getLocalComics() async {
    return _localFileSource.getLocalBooks();
  }

  Future<List<ComicPage>> extractPages(ComicBook book) async {
    if (await _archiveExtractor.isCached(book.id)) {
      return _archiveExtractor.loadFromCache(book.id);
    }
    // Use localCachePath for WebDAV files, otherwise use path
    final filePath = await _getLocalFilePath(book);
    if (filePath == null) {
      throw Exception('캐시된 파일을 찾을 수 없습니다. 다시 다운로드해주세요.');
    }
    return _archiveExtractor.extractArchive(filePath, book.id);
  }

  Future<ComicPage?> extractCover(ComicBook book) async {
    final filePath = await _getLocalFilePath(book);
    if (filePath == null) return null;
    return _archiveExtractor.extractFirstPage(filePath, book.id);
  }

  /// WebDAV 파일의 경우 로컬 캐시 경로를 찾아서 반환
  /// 로컬 파일인 경우 그대로 반환
  Future<String?> _getLocalFilePath(ComicBook book) async {
    // 로컬 파일인 경우 path 그대로 반환
    if (book.source == ComicSource.local) {
      return book.path;
    }

    // WebDAV 파일인 경우 캐시된 로컬 경로 확인
    // 1. localCachePath가 있고 파일이 존재하면 사용
    if (book.localCachePath != null) {
      if (await File(book.localCachePath!).exists()) {
        return book.localCachePath;
      }
    }

    // 2. DownloadManager에서 캐시된 경로 확인
    final cachedPath = await DownloadManager.instance.getCachedPath(book.id);
    if (cachedPath != null) {
      return cachedPath;
    }

    // 캐시된 파일이 없음 - WebDAV에서 다시 다운로드 필요
    return null;
  }

  Future<int> getPageCount(ComicBook book) async {
    final filePath = await _getLocalFilePath(book);
    if (filePath == null) return 0;
    return _archiveExtractor.getPageCount(filePath);
  }

  Future<void> deleteComic(ComicBook book) async {
    await _archiveExtractor.clearCache(book.id);
    await _localFileSource.deleteBook(book.path);
  }

  Future<void> clearCache(ComicBook book) async {
    await _archiveExtractor.clearCache(book.id);
  }
}
