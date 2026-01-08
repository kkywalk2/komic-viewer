import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/models/comic_page.dart';
import '../data/models/virtual_page.dart';
import '../providers/preferences_provider.dart';

class PageSplitService {
  PageSplitService._();

  /// 원본 페이지 목록을 가상 페이지 목록으로 변환
  /// [splitEnabled]: 분할 활성화 여부
  /// [direction]: 읽기 방향 (분할 순서 결정)
  static Future<List<VirtualPage>> createVirtualPages({
    required List<ComicPage> pages,
    required bool splitEnabled,
    required ReadingDirection direction,
  }) async {
    if (!splitEnabled) {
      // 분할 비활성화시 1:1 매핑
      return pages.asMap().entries.map((entry) {
        return VirtualPage(
          virtualIndex: entry.key,
          originalIndex: entry.key,
          path: entry.value.path,
          splitPart: SplitPart.none,
          imageWidth: 0,
          imageHeight: 0,
        );
      }).toList();
    }

    final virtualPages = <VirtualPage>[];
    int virtualIndex = 0;

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      final dimensions = await _getImageDimensions(page.path);

      if (dimensions != null && _shouldSplit(dimensions)) {
        // 가로가 긴 이미지: 분할
        // 읽기 방향에 따라 순서 결정
        final firstPart = direction == ReadingDirection.rightToLeft
            ? SplitPart.right
            : SplitPart.left;
        final secondPart = direction == ReadingDirection.rightToLeft
            ? SplitPart.left
            : SplitPart.right;

        virtualPages.add(VirtualPage(
          virtualIndex: virtualIndex++,
          originalIndex: i,
          path: page.path,
          splitPart: firstPart,
          imageWidth: dimensions.width,
          imageHeight: dimensions.height,
        ));
        virtualPages.add(VirtualPage(
          virtualIndex: virtualIndex++,
          originalIndex: i,
          path: page.path,
          splitPart: secondPart,
          imageWidth: dimensions.width,
          imageHeight: dimensions.height,
        ));
      } else {
        // 일반 이미지: 분할 안함
        virtualPages.add(VirtualPage(
          virtualIndex: virtualIndex++,
          originalIndex: i,
          path: page.path,
          splitPart: SplitPart.none,
          imageWidth: dimensions?.width ?? 0,
          imageHeight: dimensions?.height ?? 0,
        ));
      }
    }

    return virtualPages;
  }

  /// 이미지 크기 조회
  static Future<({int width, int height})?> _getImageDimensions(
      String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return (width: image.width, height: image.height);
    } catch (e) {
      debugPrint('Failed to get image dimensions: $e');
      return null;
    }
  }

  /// 분할 여부 판단 (가로/세로 비율 기준)
  static bool _shouldSplit(({int width, int height}) dimensions) {
    final aspectRatio = dimensions.width / dimensions.height;
    return aspectRatio > AppConstants.splitAspectRatioThreshold;
  }

  /// 가상 페이지 인덱스를 원본 페이지 인덱스로 변환
  static int virtualToOriginal(
      List<VirtualPage> virtualPages, int virtualIndex) {
    if (virtualIndex < 0 || virtualIndex >= virtualPages.length) {
      return 0;
    }
    return virtualPages[virtualIndex].originalIndex;
  }

  /// 원본 페이지 인덱스를 가상 페이지 인덱스로 변환
  /// (해당 원본 페이지의 첫 번째 가상 페이지 반환)
  static int originalToVirtual(
      List<VirtualPage> virtualPages, int originalIndex) {
    for (final vp in virtualPages) {
      if (vp.originalIndex == originalIndex) {
        return vp.virtualIndex;
      }
    }
    return 0;
  }
}
