import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../data/models/comic_page.dart';

class PageViewReader extends StatefulWidget {
  final List<ComicPage> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;

  const PageViewReader({
    super.key,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
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
    return GestureDetector(
      onTap: widget.onTap,
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: _pageController,
        itemCount: widget.pages.length,
        onPageChanged: widget.onPageChanged,
        builder: (context, index) {
          final page = widget.pages[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(page.path)),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: page.path),
          );
        },
        loadingBuilder: (context, event) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
