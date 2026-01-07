import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/download_task.dart';
import '../../../../providers/webdav_provider.dart';

class DownloadProgressDialog extends ConsumerWidget {
  const DownloadProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(downloadTaskProvider);

    if (task == null) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: const Text('다운로드 중'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: task.progress),
          const SizedBox(height: 8),
          Text(
            '${task.progressPercent}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (task.status == DownloadStatus.failed && task.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                task.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (task.isActive)
          TextButton(
            onPressed: () {
              ref.read(downloadTaskProvider.notifier).cancelDownload();
            },
            child: const Text('취소'),
          ),
        if (task.status == DownloadStatus.failed ||
            task.status == DownloadStatus.cancelled)
          TextButton(
            onPressed: () {
              ref.read(downloadTaskProvider.notifier).clearTask();
              Navigator.of(context).pop();
            },
            child: const Text('닫기'),
          ),
      ],
    );
  }
}

void showDownloadProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const DownloadProgressDialog(),
  );
}
