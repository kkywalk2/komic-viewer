import 'package:flutter/material.dart';

class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key});

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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 56,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 만화가 없습니다',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오른쪽 하단의 + 버튼을 눌러\n만화 파일을 추가해보세요',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
