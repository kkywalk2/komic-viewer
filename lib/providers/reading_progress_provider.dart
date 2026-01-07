import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/reading_progress.dart';
import '../data/repositories/reading_progress_repository.dart';

final continueReadingProvider = FutureProvider<List<ReadingProgress>>((ref) async {
  return ReadingProgressRepository.instance.getContinueReading();
});

final continueReadingNotifierProvider =
    StateNotifierProvider<ContinueReadingNotifier, AsyncValue<List<ReadingProgress>>>((ref) {
  return ContinueReadingNotifier();
});

class ContinueReadingNotifier extends StateNotifier<AsyncValue<List<ReadingProgress>>> {
  ContinueReadingNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final progress = await ReadingProgressRepository.instance.getContinueReading();
      state = AsyncValue.data(progress);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProgress(String id) async {
    await ReadingProgressRepository.instance.deleteProgress(id);
    await load();
  }

  Future<void> clearAll() async {
    await ReadingProgressRepository.instance.clearAll();
    state = const AsyncValue.data([]);
  }
}
