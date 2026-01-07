enum ComicSource { local, webdav }

class ComicBook {
  final String id;
  final String title;
  final String path;
  final ComicSource source;
  final String? serverId;
  final String? localCachePath;
  final String? coverPath;
  final int pageCount;
  final int fileSize;
  final DateTime addedAt;

  const ComicBook({
    required this.id,
    required this.title,
    required this.path,
    required this.source,
    this.serverId,
    this.localCachePath,
    this.coverPath,
    this.pageCount = 0,
    this.fileSize = 0,
    required this.addedAt,
  });

  ComicBook copyWith({
    String? id,
    String? title,
    String? path,
    ComicSource? source,
    String? serverId,
    String? localCachePath,
    String? coverPath,
    int? pageCount,
    int? fileSize,
    DateTime? addedAt,
  }) {
    return ComicBook(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      source: source ?? this.source,
      serverId: serverId ?? this.serverId,
      localCachePath: localCachePath ?? this.localCachePath,
      coverPath: coverPath ?? this.coverPath,
      pageCount: pageCount ?? this.pageCount,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'source': source.name,
      'server_id': serverId,
      'local_cache_path': localCachePath,
      'cover_path': coverPath,
      'page_count': pageCount,
      'file_size': fileSize,
      'added_at': addedAt.millisecondsSinceEpoch,
    };
  }

  factory ComicBook.fromMap(Map<String, dynamic> map) {
    return ComicBook(
      id: map['id'] as String,
      title: map['title'] as String,
      path: map['path'] as String,
      source: ComicSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => ComicSource.local,
      ),
      serverId: map['server_id'] as String?,
      localCachePath: map['local_cache_path'] as String?,
      coverPath: map['cover_path'] as String?,
      pageCount: map['page_count'] as int? ?? 0,
      fileSize: map['file_size'] as int? ?? 0,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicBook && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
