import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/hash_utils.dart';
import '../../../data/models/comic_book.dart';
import '../../../data/models/server_config.dart';
import '../../../data/models/download_task.dart';
import '../../../providers/webdav_provider.dart';
import 'widgets/browser_shimmer.dart';
import 'widgets/download_progress_dialog.dart';
import 'widgets/empty_browser_state.dart';
import 'widgets/webdav_item_tile.dart';

class BrowserScreen extends ConsumerWidget {
  final ServerConfig server;

  const BrowserScreen({super.key, required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(webdavBrowserProvider(server));
    final downloadTask = ref.watch(downloadTaskProvider);

    // Listen for download completion
    ref.listen<DownloadTask?>(downloadTaskProvider, (previous, next) {
      if (next != null && next.status == DownloadStatus.completed) {
        // Download completed, navigate to reader
        Navigator.of(context).pop(); // Close dialog
        _openComic(context, ref, next);
      }
    });

    return PopScope(
      canPop: !browserState.canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && browserState.canGoBack) {
          ref.read(webdavBrowserProvider(server).notifier).navigateUp();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            browserState.currentPath,
            style: const TextStyle(fontSize: 14),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (browserState.canGoBack) {
                ref.read(webdavBrowserProvider(server).notifier).navigateUp();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: browserState.isLoading
                  ? null
                  : () {
                      ref.read(webdavBrowserProvider(server).notifier).refresh();
                    },
            ),
          ],
        ),
        body: _buildBody(context, ref, browserState, downloadTask),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    WebDavBrowserState state,
    DownloadTask? downloadTask,
  ) {
    if (state.isLoading) {
      return const BrowserShimmer();
    }

    if (state.error != null) {
      return _buildErrorState(context, ref, state.error!);
    }

    if (state.items.isEmpty) {
      return const EmptyBrowserState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(webdavBrowserProvider(server).notifier).refresh();
      },
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return WebDavItemTile(
            item: item,
            onTap: () {
              if (item.isDirectory) {
                ref
                    .read(webdavBrowserProvider(server).notifier)
                    .navigateTo(item.path);
              } else {
                _downloadAndOpen(context, ref, item);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(webdavBrowserProvider(server).notifier).refresh();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpen(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
  ) async {
    showDownloadProgressDialog(context);

    await ref.read(downloadTaskProvider.notifier).downloadFile(
          server: server,
          item: item,
        );
  }

  void _openComic(BuildContext context, WidgetRef ref, DownloadTask task) {
    ref.read(downloadTaskProvider.notifier).clearTask();

    final book = ComicBook(
      id: generateBookId(ComicSource.webdav, server.id, task.remotePath),
      title: task.fileName.replaceAll(RegExp(r'\.(zip|cbz|cbr|rar)$', caseSensitive: false), ''),
      path: task.remotePath,
      source: ComicSource.webdav,
      serverId: server.id,
      localCachePath: task.localPath,
      addedAt: DateTime.now(),
    );

    context.push('/reader', extra: book);
  }
}
