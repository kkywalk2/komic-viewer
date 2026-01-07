import '../../core/utils/file_utils.dart';

class WebDavItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modifiedAt;
  final String? mimeType;

  const WebDavItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.modifiedAt,
    this.mimeType,
  });

  bool get isSupportedArchive => !isDirectory && isSupportedArchiveFile(name);

  String get formattedSize => formatFileSize(size);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebDavItem &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

bool isSupportedArchiveFile(String filename) {
  final ext = filename.toLowerCase();
  return ext.endsWith('.zip') ||
      ext.endsWith('.cbz') ||
      ext.endsWith('.cbr') ||
      ext.endsWith('.rar');
}
