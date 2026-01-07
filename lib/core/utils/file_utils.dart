import 'package:path/path.dart' as p;

const _supportedArchiveExtensions = {'.zip', '.cbz', '.cbr', '.rar'};
const _supportedImageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};

bool isSupportedArchive(String filename) {
  final ext = p.extension(filename).toLowerCase();
  return _supportedArchiveExtensions.contains(ext);
}

bool isImageFile(String filename) {
  if (filename.startsWith('.') || filename.contains('__MACOSX')) {
    return false;
  }

  final ext = p.extension(filename).toLowerCase();
  return _supportedImageExtensions.contains(ext);
}

String getTitleFromPath(String path) {
  final filename = p.basenameWithoutExtension(path);
  return filename;
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
