import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _databaseName = "chefkit.db";
  static const _databaseVersion = 3; // Bumped for webp migration

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name_en TEXT NOT NULL,
            name_fr TEXT NOT NULL,
            name_ar TEXT NOT NULL,
            type_en TEXT NOT NULL,
            type_fr TEXT NOT NULL,
            type_ar TEXT NOT NULL,
            image_path TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            recipe_id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add favorites table for existing databases
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
              recipe_id TEXT PRIMARY KEY,
              created_at INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          // Clear ingredients to reseed with webp paths
          await db.execute('DELETE FROM ingredients');
        }
      },
    );
  }
}
