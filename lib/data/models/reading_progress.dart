import 'comic_book.dart';

class ReadingProgress {
  final String id;
  final String bookId;
  final String title;
  final String? coverPath;
  final ComicSource source;
  final String? serverId;
  final String filePath;
  final int currentPage;
  final int totalPages;
  final bool isFinished;
  final DateTime lastReadAt;
  final DateTime createdAt;

  const ReadingProgress({
    required this.id,
    required this.bookId,
    required this.title,
    this.coverPath,
    required this.source,
    this.serverId,
    required this.filePath,
    required this.currentPage,
    required this.totalPages,
    this.isFinished = false,
    required this.lastReadAt,
    required this.createdAt,
  });

  double get progressPercent {
    if (totalPages == 0) return 0;
    return (currentPage + 1) / totalPages;
  }

  ReadingProgress copyWith({
    String? id,
    String? bookId,
    String? title,
    String? coverPath,
    ComicSource? source,
    String? serverId,
    String? filePath,
    int? currentPage,
    int? totalPages,
    bool? isFinished,
    DateTime? lastReadAt,
    DateTime? createdAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverPath: coverPath ?? this.coverPath,
      source: source ?? this.source,
      serverId: serverId ?? this.serverId,
      filePath: filePath ?? this.filePath,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isFinished: isFinished ?? this.isFinished,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'title': title,
      'cover_path': coverPath,
      'source': source.name,
      'server_id': serverId,
      'file_path': filePath,
      'current_page': currentPage,
      'total_pages': totalPages,
      'is_finished': isFinished ? 1 : 0,
      'last_read_at': lastReadAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      title: map['title'] as String,
      coverPath: map['cover_path'] as String?,
      source: ComicSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => ComicSource.local,
      ),
      serverId: map['server_id'] as String?,
      filePath: map['file_path'] as String,
      currentPage: map['current_page'] as int,
      totalPages: map['total_pages'] as int,
      isFinished: (map['is_finished'] as int) == 1,
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['last_read_at'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
