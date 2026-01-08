import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../data/models/virtual_page.dart';

/// 이미지의 좌/우 절반만 표시하는 위젯
class SplitImageWidget extends StatelessWidget {
  final VirtualPage page;
  final VoidCallback onTap;

  const SplitImageWidget({
    super.key,
    required this.page,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black,
        child: Center(
          child: _buildSplitImage(),
        ),
      ),
    );
  }

  Widget _buildSplitImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 원본 이미지의 절반 크기 계산
        final halfWidth = page.imageWidth / 2;
        final originalHeight = page.imageHeight.toDouble();

        // 화면에 맞추기 위한 스케일 계산
        final scaleX = constraints.maxWidth / halfWidth;
        final scaleY = constraints.maxHeight / originalHeight;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        final displayWidth = halfWidth * scale;
        final displayHeight = originalHeight * scale;

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: page.splitPart == SplitPart.left
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                maxWidth: displayWidth * 2,
                maxHeight: displayHeight,
                child: Image.file(
                  File(page.path),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
