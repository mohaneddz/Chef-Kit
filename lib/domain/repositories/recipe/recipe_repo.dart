import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:chefkit/database/db_helper.dart';
import '../../models/recipe.dart';

class RecipeRepository {
  final List<Recipe> _seedRecipes = [
    Recipe(
      id: 'r1',
      name: 'Mahjouba',
      description: 'Authentic Algerian Classic',
      imageUrl: 'assets/images/Mahjouba.jpeg',
      prepTime: 45,
      tags: ['hot'],
      ownerId: 'c1',
      ingredients: ['Semolina', 'Tomato', 'Onion', 'Garlic', 'Spices'],
    ),
    Recipe(
      id: 'r2',
      name: 'Couscous',
      description: 'Steamed semolina with veggies',
      imageUrl: 'assets/images/couscous.png',
      prepTime: 120,
      tags: ['hot'],
      ownerId: 'c2',
      ingredients: ['Couscous', 'Chicken', 'Carrots', 'Zucchini', 'Chickpeas'],
    ),
    Recipe(
      id: 'r3',
      name: 'Barkoukes',
      description: 'Traditional Soup',
      imageUrl: 'assets/images/Barkoukes.jpg',
      prepTime: 90,
      tags: ['seasonal'],
      ownerId: 'c3',
      ingredients: ['Pasta', 'Tomato', 'Meat', 'Spices', 'Vegetables'],
    ),
    Recipe(
      id: 'r4',
      name: 'Escalope',
      description: 'Delicious & Crispy',
      imageUrl: 'assets/images/ingredients/escalope.png',
      prepTime: 30,
      tags: ['hot'],
      ownerId: 'c4',
      ingredients: ['Chicken', 'Breadcrumbs', 'Egg', 'Oil', 'Lemon'],
    ),
    Recipe(
      id: 'r5',
      name: 'Strawberry Salad',
      description: 'with Balsamic Glaze',
      imageUrl: 'assets/images/ingredients/tomato.png',
      prepTime: 15,
      tags: ['seasonal'],
      ownerId: 'c5',
      ingredients: ['Strawberry', 'Spinach', 'Balsamic', 'Nuts', 'Cheese'],
    ),
  ];

  Future<void> _ensureSeeded() async {
    final db = await DBHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipes'),
    );
    if (count == 0) {
      for (var recipe in _seedRecipes) {
        final map = recipe.toJson();
        // Encode lists to JSON strings for DB storage
        map['recipe_ingredients'] = jsonEncode(recipe.ingredients);
        map['recipe_instructions'] = jsonEncode(recipe.instructions);
        map['recipe_tags'] = jsonEncode(recipe.tags);
        map['recipe_external_sources'] = jsonEncode(recipe.externalSources);
        // Ensure boolean is stored as int
        map['is_favourite'] = recipe.isFavorite ? 1 : 0;

        await db.insert('recipes', map);
      }
    }
  }

  Future<List<Recipe>> fetchHotRecipes() async {
    await _ensureSeeded();
    final db = await DBHelper.database;
    final maps = await db.query('recipes');
    final all = maps.map((e) => Recipe.fromJson(e)).toList();
    return all.where((r) => r.tags.contains('hot')).toList();
  }

  Future<List<Recipe>> fetchSeasonalRecipes() async {
    await _ensureSeeded();
    final db = await DBHelper.database;
    final maps = await db.query('recipes');
    final all = maps.map((e) => Recipe.fromJson(e)).toList();
    return all.where((r) => r.tags.contains('seasonal')).toList();
  }

  Future<List<Recipe>> fetchRecipesByChef(String chefId) async {
    await _ensureSeeded();
    final db = await DBHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'recipe_owner = ?',
      whereArgs: [chefId],
    );
    return maps.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> fetchAllRecipes() async {
    await _ensureSeeded();
    final db = await DBHelper.database;
    final maps = await db.query('recipes');
    return maps.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> fetchFavoriteRecipes() async {
    await _ensureSeeded();
    final db = await DBHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'is_favourite = ?',
      whereArgs: [1],
    );
    return maps.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<Recipe> toggleFavorite(String recipeId) async {
    await _ensureSeeded();
    final db = await DBHelper.database;

    // Get current status
    final maps = await db.query(
      'recipes',
      columns: ['is_favourite'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    if (maps.isEmpty) throw Exception('Recipe not found');

    final currentStatus = (maps.first['is_favourite'] as int?) == 1;
    final newStatus = !currentStatus;

    await db.update(
      'recipes',
      {'is_favourite': newStatus ? 1 : 0},
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    // Return updated recipe
    final updatedMaps = await db.query(
      'recipes',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return Recipe.fromJson(updatedMaps.first);
  }
}
