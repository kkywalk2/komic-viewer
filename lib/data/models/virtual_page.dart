/// 분할 부분을 나타내는 enum
enum SplitPart {
  none, // 분할되지 않음 (전체 이미지)
  left, // 왼쪽 절반
  right, // 오른쪽 절반
}

/// 가상 페이지를 나타내는 모델
/// 분할된 스프레드 페이지의 경우 하나의 ComicPage가 두 개의 VirtualPage를 생성
class VirtualPage {
  final int virtualIndex; // 가상 페이지 인덱스 (0부터 시작)
  final int originalIndex; // 원본 ComicPage 인덱스
  final String path; // 이미지 파일 경로
  final SplitPart splitPart; // 분할 부분
  final int imageWidth; // 원본 이미지 너비
  final int imageHeight; // 원본 이미지 높이

  const VirtualPage({
    required this.virtualIndex,
    required this.originalIndex,
    required this.path,
    required this.splitPart,
    required this.imageWidth,
    required this.imageHeight,
  });

  /// 이 페이지가 분할된 페이지인지 여부
  bool get isSplit => splitPart != SplitPart.none;

  @override
  String toString() {
    return 'VirtualPage(virtualIndex: $virtualIndex, originalIndex: $originalIndex, splitPart: $splitPart)';
  }
}
