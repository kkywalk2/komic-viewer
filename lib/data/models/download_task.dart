enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadTask {
  final String id;
  final String serverId;
  final String remotePath;
  final String localPath;
  final String fileName;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final String? errorMessage;

  const DownloadTask({
    required this.id,
    required this.serverId,
    required this.remotePath,
    required this.localPath,
    required this.fileName,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.pending,
    this.errorMessage,
  });

  double get progress {
    if (totalBytes == 0) return 0;
    return downloadedBytes / totalBytes;
  }

  int get progressPercent => (progress * 100).toInt();

  bool get isActive =>
      status == DownloadStatus.pending || status == DownloadStatus.downloading;

  DownloadTask copyWith({
    String? id,
    String? serverId,
    String? remotePath,
    String? localPath,
    String? fileName,
    int? totalBytes,
    int? downloadedBytes,
    DownloadStatus? status,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      remotePath: remotePath ?? this.remotePath,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
