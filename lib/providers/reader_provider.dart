import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/comic_book.dart';
import '../data/models/comic_page.dart';
import '../data/models/virtual_page.dart';
import '../data/repositories/comic_repository.dart';
import '../data/repositories/reading_progress_repository.dart';
import '../services/page_split_service.dart';
import 'preferences_provider.dart';

class ReaderState {
  final ComicBook? book;
  final List<ComicPage> pages;
  final List<VirtualPage> virtualPages;
  final int currentPage;
  final bool isLoading;
  final bool showControls;
  final String? error;

  const ReaderState({
    this.book,
    this.pages = const [],
    this.virtualPages = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.showControls = false,
    this.error,
  });

  /// 총 페이지 수 (가상 페이지 기준)
  int get totalPages => virtualPages.length;

  /// 원본 페이지 총 개수
  int get totalOriginalPages => pages.length;

  /// 현재 가상 페이지에 해당하는 원본 페이지 인덱스
  int get currentOriginalPage {
    if (virtualPages.isEmpty || currentPage >= virtualPages.length) return 0;
    return virtualPages[currentPage].originalIndex;
  }

  double get progress {
    if (totalPages == 0) return 0;
    return (currentPage + 1) / totalPages;
  }

  ReaderState copyWith({
    ComicBook? book,
    List<ComicPage>? pages,
    List<VirtualPage>? virtualPages,
    int? currentPage,
    bool? isLoading,
    bool? showControls,
    String? error,
  }) {
    return ReaderState(
      book: book ?? this.book,
      pages: pages ?? this.pages,
      virtualPages: virtualPages ?? this.virtualPages,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      showControls: showControls ?? this.showControls,
      error: error,
    );
  }
}

final readerNotifierProvider =
    StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  return ReaderNotifier(ref);
});

class ReaderNotifier extends StateNotifier<ReaderState> {
  final Ref _ref;

  ReaderNotifier(this._ref) : super(const ReaderState());

  final _comicRepository = ComicRepository.instance;
  final _progressRepository = ReadingProgressRepository.instance;

  Future<void> openBook(ComicBook book) async {
    state = state.copyWith(isLoading: true, book: book, error: null);

    try {
      final pages = await _comicRepository.extractPages(book);

      // 설정에서 분할 옵션 및 읽기 방향 가져오기
      final prefs = _ref.read(readerPreferencesNotifierProvider);

      // 가상 페이지 생성
      final virtualPages = await PageSplitService.createVirtualPages(
        pages: pages,
        splitEnabled: prefs.splitWidePages,
        direction: prefs.direction,
      );

      // 저장된 진행률 복원 (원본 페이지 기준)
      final existingProgress = await _progressRepository.getByBookId(book.id);
      final originalPage = existingProgress?.currentPage ?? 0;

      // 원본 페이지를 가상 페이지 인덱스로 변환
      final initialPage =
          PageSplitService.originalToVirtual(virtualPages, originalPage);

      state = state.copyWith(
        pages: pages,
        virtualPages: virtualPages,
        currentPage: initialPage.clamp(0, virtualPages.length - 1),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 분할 설정 또는 읽기 방향 변경 시 가상 페이지 재생성
  Future<void> refreshVirtualPages() async {
    if (state.pages.isEmpty) return;

    final prefs = _ref.read(readerPreferencesNotifierProvider);
    final currentOriginal = state.currentOriginalPage;

    final virtualPages = await PageSplitService.createVirtualPages(
      pages: state.pages,
      splitEnabled: prefs.splitWidePages,
      direction: prefs.direction,
    );

    // 현재 원본 페이지 위치 유지
    final newVirtualIndex =
        PageSplitService.originalToVirtual(virtualPages, currentOriginal);

    state = state.copyWith(
      virtualPages: virtualPages,
      currentPage: newVirtualIndex.clamp(0, virtualPages.length - 1),
    );
  }

  void goToPage(int page) {
    if (page < 0 || page >= state.totalPages) return;
    if (page == state.currentPage) return;
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

    // 원본 페이지 기준으로 저장
    await _progressRepository.saveProgress(
      book: book,
      currentPage: state.currentOriginalPage,
      totalPages: state.totalOriginalPages,
    );
  }

  Future<void> closeBook() async {
    await _saveProgress();
    state = const ReaderState();
  }
}
