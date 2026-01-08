import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reading_progress (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        cover_path TEXT,
        source TEXT NOT NULL,
        server_id TEXT,
        file_path TEXT NOT NULL,
        current_page INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        is_finished INTEGER NOT NULL DEFAULT 0,
        last_read_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reading_progress_last_read
      ON reading_progress(last_read_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_reading_progress_book_id
      ON reading_progress(book_id)
    ''');

    await db.execute('''
      CREATE TABLE server_configs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        username TEXT NOT NULL,
        password_encrypted TEXT NOT NULL,
        root_path TEXT NOT NULL DEFAULT '/',
        allow_self_signed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE thumbnails (
        book_id TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE file_cache (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        remote_path TEXT NOT NULL,
        local_path TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        downloaded_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_file_cache_book_id ON file_cache(book_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE reading_progress ADD COLUMN local_cache_path TEXT',
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
