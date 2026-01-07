class StorageKeys {
  StorageKeys._();

  static const String serverPasswordPrefix = 'server_password_';

  static String serverPasswordKey(String serverId) =>
      '$serverPasswordPrefix$serverId';
}
