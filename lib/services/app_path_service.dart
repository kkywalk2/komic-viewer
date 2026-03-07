import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPathService {
  AppPathService._();

  static final AppPathService instance = AppPathService._();

  static const String _documentsPrefix = 'app-docs:';
  static const String _supportPrefix = 'app-support:';
  static const String _cachePrefix = 'app-cache:';

  Future<String?> toManagedPath(String? absolutePath) async {
    if (absolutePath == null || absolutePath.isEmpty) return null;
    if (!p.isAbsolute(absolutePath)) return absolutePath;

    final roots = await _roots();
    for (final entry in roots.entries) {
      final rootPath = entry.value;
      if (_isSameOrWithin(rootPath, absolutePath)) {
        final relativePath = p.relative(absolutePath, from: rootPath);
        return '${entry.key}$relativePath';
      }
    }

    return null;
  }

  Future<String?> resolveManagedPath(String? storedPath) async {
    if (storedPath == null || storedPath.isEmpty) return null;

    final roots = await _roots();
    for (final entry in roots.entries) {
      if (storedPath.startsWith(entry.key)) {
        final relativePath = storedPath.substring(entry.key.length);
        return p.join(entry.value, relativePath);
      }
    }

    if (p.isAbsolute(storedPath)) {
      return null;
    }

    return storedPath;
  }

  bool isAbsolutePath(String? path) {
    if (path == null || path.isEmpty) return false;
    return p.isAbsolute(path);
  }

  Future<Map<String, String>> _roots() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final supportDir = await getApplicationSupportDirectory();
    final cacheDir = await getApplicationCacheDirectory();

    return {
      _documentsPrefix: documentsDir.path,
      _supportPrefix: supportDir.path,
      _cachePrefix: cacheDir.path,
    };
  }

  bool _isSameOrWithin(String rootPath, String targetPath) {
    return targetPath == rootPath || p.isWithin(rootPath, targetPath);
  }
}
