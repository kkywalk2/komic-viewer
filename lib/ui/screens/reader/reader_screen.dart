import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/comic_book.dart';
import '../../../providers/reader_provider.dart';
import '../../../providers/reading_progress_provider.dart';
import 'widgets/page_view_reader.dart';
import 'widgets/reader_controls.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final ComicBook book;

  const ReaderScreen({super.key, required this.book});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readerNotifierProvider.notifier).openBook(widget.book);
    });
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _handleBack() async {
    await ref.read(readerNotifierProvider.notifier).closeBook();
    ref.read(continueReadingNotifierProvider.notifier).load();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main Reader
            if (readerState.isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (readerState.error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      readerState.error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleBack,
                      child: const Text('뒤로 가기'),
                    ),
                  ],
                ),
              )
            else if (readerState.pages.isNotEmpty)
              PageViewReader(
                pages: readerState.pages,
                currentPage: readerState.currentPage,
                onPageChanged: (page) {
                  ref.read(readerNotifierProvider.notifier).goToPage(page);
                },
                onTap: () {
                  ref.read(readerNotifierProvider.notifier).toggleControls();
                },
              ),

            // Controls Overlay
            if (readerState.showControls)
              ReaderControls(
                title: widget.book.title,
                currentPage: readerState.currentPage,
                totalPages: readerState.totalPages,
                onBack: _handleBack,
                onPageChanged: (page) {
                  ref.read(readerNotifierProvider.notifier).goToPage(page);
                },
              ),
          ],
        ),
      ),
    );
  }
}
