import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../data/models/virtual_page.dart';
import 'split_image_widget.dart';

class PageViewReader extends StatefulWidget {
  final List<VirtualPage> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;
  final bool reverse;

  const PageViewReader({
    super.key,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
    this.reverse = false,
  });

  @override
  State<PageViewReader> createState() => _PageViewReaderState();
}

class _PageViewReaderState extends State<PageViewReader> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage);
  }

  @override
  void didUpdateWidget(PageViewReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          final currentControllerPage = _pageController.page?.round() ?? 0;
          if (currentControllerPage != widget.currentPage) {
            _pageController.jumpToPage(widget.currentPage);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      reverse: widget.reverse,
      itemCount: widget.pages.length,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final page = widget.pages[index];

        if (page.isSplit) {
          // 분할된 페이지
          return SplitImageWidget(
            page: page,
            onTap: widget.onTap,
          );
        }

        // 일반 페이지 (기존 PhotoView 사용)
        return GestureDetector(
          onTap: widget.onTap,
          child: PhotoView(
            imageProvider: FileImage(File(page.path)),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        );
      },
    );
  }
}
