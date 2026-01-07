import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/natural_sort.dart';
import '../../models/server_config.dart';
import '../../models/webdav_item.dart';

class WebDavSource {
  final ServerConfig server;
  late final webdav.Client _client;

  WebDavSource(this.server) {
    _client = webdav.newClient(
      server.url,
      user: server.username,
      password: server.password,
      debug: false,
    );

    // Handle self-signed certificates
    if (server.allowSelfSigned) {
      _client.setVerify(false);
    }

    // Set timeouts
    _client.setConnectTimeout(AppConstants.connectionTimeoutSeconds * 1000);
    _client.setSendTimeout(AppConstants.downloadTimeoutSeconds * 1000);
    _client.setReceiveTimeout(AppConstants.downloadTimeoutSeconds * 1000);
  }

  Future<bool> testConnection() async {
    try {
      await _client.readDir(server.rootPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<WebDavItem>> listDirectory(String path) async {
    try {
      final files = await _client.readDir(path);

      final items = files
          .where((f) => f.name != null && !f.name!.startsWith('.'))
          .map((f) => WebDavItem(
                name: f.name!,
                path: f.path ?? '',
                isDirectory: f.isDir ?? false,
                size: f.size ?? 0,
                modifiedAt: f.mTime,
                mimeType: f.mimeType,
              ))
          .where((item) => item.isDirectory || item.isSupportedArchive)
          .toList();

      // Sort: directories first, then files, natural sort
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return naturalCompare(a.name, b.name);
      });

      return items;
    } on webdav.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw AuthException('인증에 실패했습니다');
      } else if (statusCode == 404) {
        throw NotFoundException('경로를 찾을 수 없습니다: $path');
      }
      throw WebDavException('WebDAV 오류: ${e.message}', statusCode);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('certificate') || errorStr.contains('ssl')) {
        throw SSLException('SSL 인증서 오류');
      }
      if (errorStr.contains('connection') ||
          errorStr.contains('socket') ||
          errorStr.contains('network')) {
        throw NetworkException('연결할 수 없습니다');
      }
      throw WebDavException('오류: $e');
    }
  }

  Future<void> downloadFile({
    required String remotePath,
    required String localPath,
    required void Function(int received, int total) onProgress,
  }) async {
    try {
      await _client.read2File(
        remotePath,
        localPath,
        onProgress: onProgress,
      );
    } on webdav.DioException catch (e) {
      throw WebDavException('다운로드 실패: ${e.message}');
    } catch (e) {
      throw WebDavException('다운로드 오류: $e');
    }
  }
}
