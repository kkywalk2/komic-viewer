import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

enum LibraryViewMode { grid, list }

enum SortOption {
  titleAsc,
  titleDesc,
  dateDesc,
  dateAsc,
  sizeDesc,
  sizeAsc,
}

enum ReadingDirection {
  leftToRight,
  rightToLeft,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.titleAsc:
        return '제목 (가-하)';
      case SortOption.titleDesc:
        return '제목 (하-가)';
      case SortOption.dateDesc:
        return '추가일 (최신순)';
      case SortOption.dateAsc:
        return '추가일 (오래된순)';
      case SortOption.sizeDesc:
        return '크기 (큰순)';
      case SortOption.sizeAsc:
        return '크기 (작은순)';
    }
  }
}

extension ReadingDirectionExtension on ReadingDirection {
  String get displayName {
    switch (this) {
      case ReadingDirection.leftToRight:
        return '왼쪽 → 오른쪽';
      case ReadingDirection.rightToLeft:
        return '오른쪽 → 왼쪽 (만화)';
    }
  }
}

class LibraryPreferences {
  final LibraryViewMode viewMode;
  final SortOption sortOption;

  const LibraryPreferences({
    this.viewMode = LibraryViewMode.grid,
    this.sortOption = SortOption.dateDesc,
  });

  LibraryPreferences copyWith({
    LibraryViewMode? viewMode,
    SortOption? sortOption,
  }) {
    return LibraryPreferences(
      viewMode: viewMode ?? this.viewMode,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class ReaderPreferences {
  final ReadingDirection direction;
  final bool keepScreenOn;
  final bool splitWidePages;

  const ReaderPreferences({
    this.direction = ReadingDirection.leftToRight,
    this.keepScreenOn = true,
    this.splitWidePages = true,
  });

  ReaderPreferences copyWith({
    ReadingDirection? direction,
    bool? keepScreenOn,
    bool? splitWidePages,
  }) {
    return ReaderPreferences(
      direction: direction ?? this.direction,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      splitWidePages: splitWidePages ?? this.splitWidePages,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, LibraryPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesNotifier(prefs);
});

class PreferencesNotifier extends StateNotifier<LibraryPreferences> {
  final SharedPreferences _prefs;

  PreferencesNotifier(this._prefs) : super(const LibraryPreferences()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final viewModeStr = _prefs.getString(AppConstants.prefViewMode);
    final sortOptionStr = _prefs.getString(AppConstants.prefSortOption);

    state = LibraryPreferences(
      viewMode:
          viewModeStr == 'list' ? LibraryViewMode.list : LibraryViewMode.grid,
      sortOption: SortOption.values.firstWhere(
        (e) => e.name == sortOptionStr,
        orElse: () => SortOption.dateDesc,
      ),
    );
  }

  Future<void> setViewMode(LibraryViewMode mode) async {
    await _prefs.setString(AppConstants.prefViewMode, mode.name);
    state = state.copyWith(viewMode: mode);
  }

  Future<void> setSortOption(SortOption option) async {
    await _prefs.setString(AppConstants.prefSortOption, option.name);
    state = state.copyWith(sortOption: option);
  }

  void toggleViewMode() {
    final newMode = state.viewMode == LibraryViewMode.grid
        ? LibraryViewMode.list
        : LibraryViewMode.grid;
    setViewMode(newMode);
  }
}

final libraryViewModeProvider = Provider<LibraryViewMode>((ref) {
  return ref.watch(preferencesNotifierProvider).viewMode;
});

final librarySortOptionProvider = Provider<SortOption>((ref) {
  return ref.watch(preferencesNotifierProvider).sortOption;
});

// Reader Preferences
final readerPreferencesNotifierProvider =
    StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReaderPreferencesNotifier(prefs);
});

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferences> {
  final SharedPreferences _prefs;

  ReaderPreferencesNotifier(this._prefs) : super(const ReaderPreferences()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final directionStr = _prefs.getString(AppConstants.prefReadingDirection);
    final keepScreenOn = _prefs.getBool(AppConstants.prefKeepScreenOn) ?? true;
    final splitWidePages =
        _prefs.getBool(AppConstants.prefSplitWidePages) ?? true;

    state = ReaderPreferences(
      direction: ReadingDirection.values.firstWhere(
        (e) => e.name == directionStr,
        orElse: () => ReadingDirection.leftToRight,
      ),
      keepScreenOn: keepScreenOn,
      splitWidePages: splitWidePages,
    );
  }

  Future<void> setReadingDirection(ReadingDirection direction) async {
    await _prefs.setString(AppConstants.prefReadingDirection, direction.name);
    state = state.copyWith(direction: direction);
  }

  Future<void> setKeepScreenOn(bool value) async {
    await _prefs.setBool(AppConstants.prefKeepScreenOn, value);
    state = state.copyWith(keepScreenOn: value);
  }

  Future<void> setSplitWidePages(bool value) async {
    await _prefs.setBool(AppConstants.prefSplitWidePages, value);
    state = state.copyWith(splitWidePages: value);
  }
}

final readingDirectionProvider = Provider<ReadingDirection>((ref) {
  return ref.watch(readerPreferencesNotifierProvider).direction;
});

final keepScreenOnProvider = Provider<bool>((ref) {
  return ref.watch(readerPreferencesNotifierProvider).keepScreenOn;
});

final splitWidePagesProvider = Provider<bool>((ref) {
  return ref.watch(readerPreferencesNotifierProvider).splitWidePages;
});
