import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chef_kit.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        user_full_name TEXT,
        user_email TEXT,
        user_phone_number TEXT,
        user_password TEXT,
        user_avatar TEXT,
        user_inventory TEXT,
        user_favourite_recipes TEXT,
        user_notifications_history TEXT,
        user_notifications_enabled INTEGER,
        user_dark_mode_enabled INTEGER,
        user_language TEXT,
        user_following_count INTEGER,
        user_recipes_count INTEGER,
        user_followers_count INTEGER,
        user_is_chef INTEGER,
        user_is_on_fire INTEGER,
        user_bio TEXT,
        user_specialties TEXT,
        user_recipes TEXT,
        user_devices TEXT,
        user_creation_date TEXT,
        user_chef_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ingredients (
        ingredient_id TEXT PRIMARY KEY,
        ingredient_name TEXT,
        ingredient_category TEXT,
        ingredient_image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        notification_id TEXT PRIMARY KEY,
        user_id TEXT,
        notification_title TEXT,
        notification_type TEXT,
        notification_message TEXT,
        notification_data TEXT,
        notification_is_read INTEGER,
        notification_created_at TEXT
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
        recipe_items TEXT,
        recipe_tags TEXT,
        recipe_external_sources TEXT
      )
    ''');
  }

  // Helper methods to insert and retrieve data can be added here
}
