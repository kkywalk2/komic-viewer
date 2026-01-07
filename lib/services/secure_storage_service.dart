import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/storage_keys.dart';

class SecureStorageService {
  static SecureStorageService? _instance;
  final FlutterSecureStorage _storage;

  SecureStorageService._()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  Future<void> saveServerPassword(String serverId, String password) async {
    await _storage.write(
      key: StorageKeys.serverPasswordKey(serverId),
      value: password,
    );
  }

  Future<String?> getServerPassword(String serverId) async {
    return await _storage.read(
      key: StorageKeys.serverPasswordKey(serverId),
    );
  }

  Future<void> deleteServerPassword(String serverId) async {
    await _storage.delete(
      key: StorageKeys.serverPasswordKey(serverId),
    );
  }

  Future<void> deleteAllServerPasswords() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(StorageKeys.serverPasswordPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
