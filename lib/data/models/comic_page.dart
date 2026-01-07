class ComicPage {
  final int index;
  final String path;
  final String originalName;

  const ComicPage({
    required this.index,
    required this.path,
    required this.originalName,
  });

  ComicPage copyWith({
    int? index,
    String? path,
    String? originalName,
  }) {
    return ComicPage(
      index: index ?? this.index,
      path: path ?? this.path,
      originalName: originalName ?? this.originalName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicPage &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          path == other.path;

  @override
  int get hashCode => Object.hash(index, path);
}
