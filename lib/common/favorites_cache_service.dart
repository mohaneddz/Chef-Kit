import 'package:sqflite/sqflite.dart';
import '../domain/db_helper.dart';

/// Service for caching favorite recipe IDs locally using SQLite.
/// This provides immediate persistence before syncing to the server.
class FavoritesCacheService {
  /// Get all cached favorite recipe IDs
  Future<Set<String>> getFavoriteIds() async {
    final db = await DBHelper.database;
    final results = await db.query('favorites');
    return results.map((row) => row['recipe_id'] as String).toSet();
  }

  /// Add a recipe to the favorites cache
  Future<void> addFavorite(String recipeId) async {
    final db = await DBHelper.database;
    await db.insert('favorites', {
      'recipe_id': recipeId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Remove a recipe from the favorites cache
  Future<void> removeFavorite(String recipeId) async {
    final db = await DBHelper.database;
    await db.delete('favorites', where: 'recipe_id = ?', whereArgs: [recipeId]);
  }

  /// Toggle favorite status and return the new state
  Future<bool> toggleFavorite(String recipeId) async {
    final isCurrentlyFavorite = await isFavorite(recipeId);

    if (isCurrentlyFavorite) {
      await removeFavorite(recipeId);
      return false;
    } else {
      await addFavorite(recipeId);
      return true;
    }
  }

  /// Check if a recipe is favorited locally
  Future<bool> isFavorite(String recipeId) async {
    final db = await DBHelper.database;
    final results = await db.query(
      'favorites',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  /// Sync local cache with server data.
  /// Call this on app start after fetching favorite IDs from server.
  Future<void> syncFromServer(List<String> serverFavoriteIds) async {
    final db = await DBHelper.database;

    // Use a transaction for atomic update
    await db.transaction((txn) async {
      // Clear existing favorites
      await txn.delete('favorites');

      // Insert all server favorites
      final batch = txn.batch();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in serverFavoriteIds) {
        batch.insert('favorites', {'recipe_id': id, 'created_at': now});
      }
      await batch.commit(noResult: true);
    });
  }
}
