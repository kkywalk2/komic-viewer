class AppConstants {
  AppConstants._();

  static const String appName = '만화 리더';
  static const String dbName = 'comic_reader.db';
  static const int dbVersion = 2;

  static const int preloadAhead = 2;
  static const int preloadBehind = 2;
  static const int keepInMemory = 4;

  static const int thumbnailMaxWidth = 200;
  static const int thumbnailMaxHeight = 300;

  static const int maxRecentBooks = 10;

  // Preference keys
  static const String prefViewMode = 'library_view_mode';
  static const String prefSortOption = 'library_sort_option';
  static const String prefReadingDirection = 'reading_direction';
  static const String prefKeepScreenOn = 'keep_screen_on';

  // Shimmer configuration
  static const int shimmerGridItemCount = 9;
  static const int shimmerListItemCount = 6;
  static const int shimmerContinueReadingCount = 4;

  // WebDAV configuration
  static const int connectionTimeoutSeconds = 30;
  static const int downloadTimeoutSeconds = 300;
  static const int maxConcurrentDownloads = 1;
  static const int maxDownloadCacheMB = 512;
}
