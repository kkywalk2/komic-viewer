abstract class AppException implements Exception {
  final String message;
  final String koreanMessage;

  AppException(this.message, this.koreanMessage);

  @override
  String toString() => koreanMessage;
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'Network error', '인터넷 연결이 없습니다');
}

class AuthException extends AppException {
  AuthException([String? message])
      : super(message ?? 'Authentication failed', '인증에 실패했습니다');
}

class WebDavException extends AppException {
  final int? statusCode;

  WebDavException(String message, [this.statusCode])
      : super(message, 'WebDAV 오류가 발생했습니다');
}

class SSLException extends AppException {
  SSLException([String? message])
      : super(message ?? 'SSL error', 'SSL 인증서 오류');
}

class DownloadCancelledException extends AppException {
  DownloadCancelledException()
      : super('Download cancelled', '다운로드가 취소되었습니다');
}

class StorageException extends AppException {
  StorageException([String? message])
      : super(message ?? 'Storage error', '저장 공간이 부족합니다');
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message ?? 'Not found', '항목을 찾을 수 없습니다');
}
