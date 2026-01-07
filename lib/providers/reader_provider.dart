import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/comic_book.dart';
import '../data/models/comic_page.dart';
import '../data/repositories/comic_repository.dart';
import '../data/repositories/reading_progress_repository.dart';

class ReaderState {
  final ComicBook? book;
  final List<ComicPage> pages;
  final int currentPage;
  final bool isLoading;
  final bool showControls;
  final String? error;

  const ReaderState({
    this.book,
    this.pages = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.showControls = false,
    this.error,
  });

  int get totalPages => pages.length;

  double get progress {
    if (totalPages == 0) return 0;
    return (currentPage + 1) / totalPages;
  }

  ReaderState copyWith({
    ComicBook? book,
    List<ComicPage>? pages,
    int? currentPage,
    bool? isLoading,
    bool? showControls,
    String? error,
  }) {
    return ReaderState(
      book: book ?? this.book,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      showControls: showControls ?? this.showControls,
      error: error,
    );
  }
}

final readerNotifierProvider =
    StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  return ReaderNotifier();
});

class ReaderNotifier extends StateNotifier<ReaderState> {
  ReaderNotifier() : super(const ReaderState());

  final _comicRepository = ComicRepository.instance;
  final _progressRepository = ReadingProgressRepository.instance;

  Future<void> openBook(ComicBook book) async {
    state = state.copyWith(isLoading: true, book: book, error: null);

    try {
      final pages = await _comicRepository.extractPages(book);

      final existingProgress = await _progressRepository.getByBookId(book.id);
      final initialPage = existingProgress?.currentPage ?? 0;

      state = state.copyWith(
        pages: pages,
        currentPage: initialPage.clamp(0, pages.length - 1),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= state.totalPages) return;
    state = state.copyWith(currentPage: page);
    _saveProgress();
  }

  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      goToPage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      goToPage(state.currentPage - 1);
    }
  }

  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
  }

  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
  }

  void hideControls() {
    state = state.copyWith(showControls: false);
  }

  Future<void> _saveProgress() async {
    final book = state.book;
    if (book == null) return;

    await _progressRepository.saveProgress(
      book: book,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
    );
  }

  Future<void> closeBook() async {
    await _saveProgress();
    state = const ReaderState();
  }
}
