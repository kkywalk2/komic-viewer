import 'package:flutter/material.dart';

class ReaderControls extends StatelessWidget {
  final String title;
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final ValueChanged<int> onPageChanged;

  const ReaderControls({
    super.key,
    required this.title,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Slider
                  if (totalPages > 1)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: currentPage.toDouble(),
                        min: 0,
                        max: (totalPages - 1).toDouble(),
                        onChanged: (value) {
                          onPageChanged(value.round());
                        },
                      ),
                    ),
                  // Page Indicator
                  Text(
                    '${currentPage + 1} / $totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
