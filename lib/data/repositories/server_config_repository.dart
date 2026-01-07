import 'package:uuid/uuid.dart';

import '../../services/secure_storage_service.dart';
import '../models/server_config.dart';
import '../sources/local/database_helper.dart';

class ServerConfigRepository {
  static ServerConfigRepository? _instance;
  final _uuid = const Uuid();

  ServerConfigRepository._();

  static ServerConfigRepository get instance {
    _instance ??= ServerConfigRepository._();
    return _instance!;
  }

  Future<List<ServerConfig>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'server_configs',
      orderBy: 'created_at DESC',
    );

    final configs = <ServerConfig>[];
    for (final map in results) {
      final config = ServerConfig.fromMap(map);
      final password =
          await SecureStorageService.instance.getServerPassword(config.id);
      configs.add(config.copyWith(password: password ?? ''));
    }
    return configs;
  }

  Future<ServerConfig?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'server_configs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final config = ServerConfig.fromMap(results.first);
    final password =
        await SecureStorageService.instance.getServerPassword(id);
    return config.copyWith(password: password ?? '');
  }

  Future<ServerConfig> save(ServerConfig config) async {
    final db = await DatabaseHelper.instance.database;
    final isNew = config.id.isEmpty;
    final serverId = isNew ? _uuid.v4() : config.id;

    // Save password to secure storage
    await SecureStorageService.instance.saveServerPassword(
      serverId,
      config.password,
    );

    // Save config to database with placeholder for password
    final configToSave = config.copyWith(
      id: serverId,
      password: '[SECURE]',
    );

    if (isNew) {
      await db.insert('server_configs', configToSave.toMap());
    } else {
      await db.update(
        'server_configs',
        configToSave.toMap(),
        where: 'id = ?',
        whereArgs: [serverId],
      );
    }

    return config.copyWith(id: serverId);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;

    // Delete password from secure storage
    await SecureStorageService.instance.deleteServerPassword(id);

    // Delete from database
    await db.delete(
      'server_configs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
