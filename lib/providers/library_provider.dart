import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/comic_book.dart';
import '../data/repositories/comic_repository.dart';

final localComicsProvider = FutureProvider<List<ComicBook>>((ref) async {
  return ComicRepository.instance.getLocalComics();
});

final libraryNotifierProvider =
    StateNotifierProvider<LibraryNotifier, AsyncValue<List<ComicBook>>>((ref) {
  return LibraryNotifier();
});

class LibraryNotifier extends StateNotifier<AsyncValue<List<ComicBook>>> {
  LibraryNotifier() : super(const AsyncValue.loading()) {
    loadComics();
  }

  Future<void> loadComics() async {
    state = const AsyncValue.loading();
    try {
      final comics = await ComicRepository.instance.getLocalComics();
      state = AsyncValue.data(comics);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ComicBook?> importComic() async {
    try {
      final book = await ComicRepository.instance.pickAndImportComic();
      if (book != null) {
        await loadComics();
      }
      return book;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteComic(ComicBook book) async {
    await ComicRepository.instance.deleteComic(book);
    await loadComics();
  }
}
