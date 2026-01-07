import '../models/comic_book.dart';
import '../models/comic_page.dart';
import '../sources/local/archive_extractor.dart';
import '../sources/local/local_file_source.dart';

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
    return _archiveExtractor.extractArchive(book.path, book.id);
  }

  Future<ComicPage?> extractCover(ComicBook book) async {
    return _archiveExtractor.extractFirstPage(book.path, book.id);
  }

  Future<int> getPageCount(ComicBook book) async {
    return _archiveExtractor.getPageCount(book.path);
  }

  Future<void> deleteComic(ComicBook book) async {
    await _archiveExtractor.clearCache(book.id);
    await _localFileSource.deleteBook(book.path);
  }

  Future<void> clearCache(ComicBook book) async {
    await _archiveExtractor.clearCache(book.id);
  }
}
