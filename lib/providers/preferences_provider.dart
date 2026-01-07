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
