class AppConstants {
  AppConstants._();

  static const String appName = '만화 리더';
  static const String dbName = 'comic_reader.db';
  static const int dbVersion = 1;

  static const int preloadAhead = 2;
  static const int preloadBehind = 2;
  static const int keepInMemory = 4;

  static const int thumbnailMaxWidth = 200;
  static const int thumbnailMaxHeight = 300;

  static const int maxRecentBooks = 10;
}
