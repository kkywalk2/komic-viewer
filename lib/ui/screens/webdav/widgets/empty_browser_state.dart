import 'package:flutter/material.dart';

class EmptyBrowserState extends StatelessWidget {
  const EmptyBrowserState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '이 폴더는 비어있습니다',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '지원하는 만화 파일이 없습니다',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
