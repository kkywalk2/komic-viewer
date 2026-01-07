import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/download_task.dart';
import '../data/models/server_config.dart';
import '../data/models/webdav_item.dart';
import '../data/repositories/server_config_repository.dart';
import '../data/sources/remote/webdav_source.dart';
import '../services/download_manager.dart';

// Server Config Providers

final serverConfigsProvider =
    StateNotifierProvider<ServerConfigNotifier, AsyncValue<List<ServerConfig>>>(
        (ref) {
  return ServerConfigNotifier();
});

class ServerConfigNotifier
    extends StateNotifier<AsyncValue<List<ServerConfig>>> {
  ServerConfigNotifier() : super(const AsyncValue.loading()) {
    loadServers();
  }

  Future<void> loadServers() async {
    state = const AsyncValue.loading();
    try {
      final servers = await ServerConfigRepository.instance.getAll();
      state = AsyncValue.data(servers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ServerConfig> addServer(ServerConfig config) async {
    final saved = await ServerConfigRepository.instance.save(config);
    await loadServers();
    return saved;
  }

  Future<void> updateServer(ServerConfig config) async {
    await ServerConfigRepository.instance.save(config);
    await loadServers();
  }

  Future<void> deleteServer(String id) async {
    await ServerConfigRepository.instance.delete(id);
    await loadServers();
  }

  Future<bool> testConnection(ServerConfig config) async {
    final webdavSource = WebDavSource(config);
    return await webdavSource.testConnection();
  }
}

// Browser State

class WebDavBrowserState {
  final String currentPath;
  final List<WebDavItem> items;
  final bool isLoading;
  final String? error;
  final List<String> pathHistory;

  const WebDavBrowserState({
    required this.currentPath,
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.pathHistory = const [],
  });

  WebDavBrowserState copyWith({
    String? currentPath,
    List<WebDavItem>? items,
    bool? isLoading,
    String? error,
    List<String>? pathHistory,
  }) {
    return WebDavBrowserState(
      currentPath: currentPath ?? this.currentPath,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pathHistory: pathHistory ?? this.pathHistory,
    );
  }

  bool get canGoBack => pathHistory.isNotEmpty;
}

final webdavBrowserProvider = StateNotifierProvider.family<
    WebDavBrowserNotifier, WebDavBrowserState, ServerConfig>(
  (ref, server) => WebDavBrowserNotifier(server),
);

class WebDavBrowserNotifier extends StateNotifier<WebDavBrowserState> {
  final ServerConfig server;
  late final WebDavSource _webdavSource;

  WebDavBrowserNotifier(this.server)
      : super(WebDavBrowserState(currentPath: server.rootPath)) {
    _webdavSource = WebDavSource(server);
    loadDirectory(server.rootPath);
  }

  Future<void> loadDirectory(String path) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = await _webdavSource.listDirectory(path);
      state = state.copyWith(
        currentPath: path,
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> navigateTo(String path) async {
    final newHistory = [...state.pathHistory, state.currentPath];
    state = state.copyWith(pathHistory: newHistory);
    await loadDirectory(path);
  }

  Future<void> navigateUp() async {
    if (state.pathHistory.isEmpty) return;

    final previousPath = state.pathHistory.last;
    final newHistory = state.pathHistory.sublist(0, state.pathHistory.length - 1);
    state = state.copyWith(pathHistory: newHistory);
    await loadDirectory(previousPath);
  }

  Future<void> refresh() async {
    await loadDirectory(state.currentPath);
  }
}

// Download Provider

final downloadTaskProvider =
    StateNotifierProvider<DownloadTaskNotifier, DownloadTask?>((ref) {
  return DownloadTaskNotifier();
});

class DownloadTaskNotifier extends StateNotifier<DownloadTask?> {
  DownloadTaskNotifier() : super(null);

  Future<String?> downloadFile({
    required ServerConfig server,
    required WebDavItem item,
  }) async {
    state = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: server.id,
      remotePath: item.path,
      localPath: '',
      fileName: item.name,
      totalBytes: item.size,
      status: DownloadStatus.downloading,
    );

    try {
      final localPath = await DownloadManager.instance.downloadAndCache(
        server: server,
        item: item,
        onProgress: (received, total) {
          state = state?.copyWith(
            downloadedBytes: received,
            totalBytes: total > 0 ? total : item.size,
          );
        },
      );

      state = state?.copyWith(
        localPath: localPath,
        status: DownloadStatus.completed,
      );

      return localPath;
    } catch (e) {
      state = state?.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void cancelDownload() {
    DownloadManager.instance.cancelCurrentDownload();
    state = state?.copyWith(status: DownloadStatus.cancelled);
  }

  void clearTask() {
    state = null;
  }
}
