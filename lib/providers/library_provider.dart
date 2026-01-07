import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/natural_sort.dart';
import '../data/models/comic_book.dart';
import '../data/repositories/comic_repository.dart';
import 'preferences_provider.dart';

final localComicsProvider = FutureProvider<List<ComicBook>>((ref) async {
  return ComicRepository.instance.getLocalComics();
});

final libraryNotifierProvider =
    StateNotifierProvider<LibraryNotifier, AsyncValue<List<ComicBook>>>((ref) {
  final sortOption = ref.watch(librarySortOptionProvider);
  return LibraryNotifier(sortOption);
});

class LibraryNotifier extends StateNotifier<AsyncValue<List<ComicBook>>> {
  SortOption _sortOption;

  LibraryNotifier(this._sortOption) : super(const AsyncValue.loading()) {
    loadComics();
  }

  void updateSortOption(SortOption option) {
    _sortOption = option;
    state.whenData((comics) {
      state = AsyncValue.data(_sortComics(comics));
    });
  }

  List<ComicBook> _sortComics(List<ComicBook> comics) {
    final sorted = List<ComicBook>.from(comics);

    switch (_sortOption) {
      case SortOption.titleAsc:
        sorted.sortNatural((c) => c.title);
        break;
      case SortOption.titleDesc:
        sorted.sortNatural((c) => c.title);
        return sorted.reversed.toList();
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      case SortOption.sizeDesc:
        sorted.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case SortOption.sizeAsc:
        sorted.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
    }

    return sorted;
  }

  Future<void> loadComics() async {
    state = const AsyncValue.loading();
    try {
      final comics = await ComicRepository.instance.getLocalComics();
      state = AsyncValue.data(_sortComics(comics));
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
