import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _databaseName = "chefkit.db";
  static const _databaseVersion = 1;

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
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            image_path TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE recipes (
            recipe_id TEXT PRIMARY KEY,
            recipe_name TEXT,
            recipe_description TEXT,
            recipe_image_url TEXT,
            recipe_owner TEXT,
            recipe_servings_count INTEGER,
            recipe_prep_time INTEGER,
            recipe_cook_time INTEGER,
            recipe_calories INTEGER,
            recipe_ingredients TEXT,
            recipe_instructions TEXT,
            recipe_items TEXT,
            recipe_tags TEXT,
            recipe_external_sources TEXT,
            is_favourite INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
}
