import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/storage_keys.dart';

class SecureStorageService {
  static SecureStorageService? _instance;
  final FlutterSecureStorage _storage;
  bool _useSharedPrefs = false;

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
    final key = StorageKeys.serverPasswordKey(serverId);
    try {
      if (_useSharedPrefs || Platform.isMacOS) {
        // Fallback to SharedPreferences on macOS (less secure, but works without signing)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, password);
      } else {
        await _storage.write(key: key, value: password);
      }
    } catch (e) {
      // Fallback to SharedPreferences if secure storage fails
      _useSharedPrefs = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, password);
    }
  }

  Future<String?> getServerPassword(String serverId) async {
    final key = StorageKeys.serverPasswordKey(serverId);
    try {
      if (_useSharedPrefs || Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      }
      return await _storage.read(key: key);
    } catch (e) {
      _useSharedPrefs = true;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> deleteServerPassword(String serverId) async {
    final key = StorageKeys.serverPasswordKey(serverId);
    try {
      if (_useSharedPrefs || Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } else {
        await _storage.delete(key: key);
      }
    } catch (e) {
      _useSharedPrefs = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }

  Future<void> deleteAllServerPasswords() async {
    try {
      if (_useSharedPrefs || Platform.isMacOS) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys().where(
              (key) => key.startsWith(StorageKeys.serverPasswordPrefix),
            );
        for (final key in keys) {
          await prefs.remove(key);
        }
      } else {
        final all = await _storage.readAll();
        for (final key in all.keys) {
          if (key.startsWith(StorageKeys.serverPasswordPrefix)) {
            await _storage.delete(key: key);
          }
        }
      }
    } catch (e) {
      _useSharedPrefs = true;
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
            (key) => key.startsWith(StorageKeys.serverPasswordPrefix),
          );
      for (final key in keys) {
        await prefs.remove(key);
      }
    }
  }
}
