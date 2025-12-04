import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/recipe.dart';
import '../database/database_helper.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';

class LocalRecipeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Seed data if empty
  Future<void> seedData() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipes'),
    );

    if (count == 0) {
      // Insert sample recipes
      final recipes = [
        LocalRecipeModel(
          recipeId: 'r1',
          recipeName: 'Mahjouba',
          recipeDescription: 'Authentic Algerian Classic',
          recipeImageUrl: 'assets/images/Mahjouba.jpeg',
          recipeOwner: 'c1',
          recipeServingsCount: 4,
          recipePrepTime: 30,
          recipeCookTime: 15,
          recipeCalories: 450,
          recipeIngredients: ['Semolina', 'Tomato', 'Onion', 'Spices'],
          recipeItems: [],
          recipeTags: ['hot', 'traditional'],
          recipeExternalSources: [],
        ),
        LocalRecipeModel(
          recipeId: 'r2',
          recipeName: 'Couscous',
          recipeDescription: 'Steamed semolina with veggies',
          recipeImageUrl: 'assets/images/couscous.png',
          recipeOwner: 'c2',
          recipeServingsCount: 6,
          recipePrepTime: 60,
          recipeCookTime: 60,
          recipeCalories: 600,
          recipeIngredients: ['Couscous', 'Carrots', 'Zucchini', 'Lamb'],
          recipeItems: [],
          recipeTags: ['hot', 'traditional'],
          recipeExternalSources: [],
        ),
        LocalRecipeModel(
          recipeId: 'r3',
          recipeName: 'Barkoukes',
          recipeDescription: 'Traditional Soup',
          recipeImageUrl: 'assets/images/Barkoukes.jpg',
          recipeOwner: 'c3',
          recipeServingsCount: 5,
          recipePrepTime: 45,
          recipeCookTime: 45,
          recipeCalories: 550,
          recipeIngredients: [
            'Pasta pearls',
            'Tomato sauce',
            'Meat',
            'Vegetables',
          ],
          recipeItems: [],
          recipeTags: ['seasonal', 'soup'],
          recipeExternalSources: [],
        ),
        LocalRecipeModel(
          recipeId: 'r4',
          recipeName: 'Escalope',
          recipeDescription: 'Delicious & Crispy',
          recipeImageUrl: 'assets/images/escalope.png',
          recipeOwner: 'c4',
          recipeServingsCount: 2,
          recipePrepTime: 15,
          recipeCookTime: 15,
          recipeCalories: 400,
          recipeIngredients: ['Chicken breast', 'Breadcrumbs', 'Egg', 'Oil'],
          recipeItems: [],
          recipeTags: ['hot', 'quick'],
          recipeExternalSources: [],
        ),
        LocalRecipeModel(
          recipeId: 'r5',
          recipeName: 'Strawberry Salad',
          recipeDescription: 'with Balsamic Glaze',
          recipeImageUrl: 'assets/images/tomato.png',
          recipeOwner: 'c5',
          recipeServingsCount: 2,
          recipePrepTime: 15,
          recipeCookTime: 0,
          recipeCalories: 200,
          recipeIngredients: [
            'Strawberries',
            'Spinach',
            'Balsamic vinegar',
            'Nuts',
          ],
          recipeItems: [],
          recipeTags: ['seasonal', 'salad'],
          recipeExternalSources: [],
        ),
      ];

      for (var recipe in recipes) {
        await db.insert('recipes', recipe.toMap());
      }

      // Insert sample user with favourites
      final user = LocalUserModel(
        userId: 'u1',
        userFullName: 'John Doe',
        userEmail: 'john@example.com',
        userPhoneNumber: '1234567890',
        userPassword: 'password',
        userAvatar: 'assets/images/chefs/chef1.png',
        userInventory: [],
        userFavouriteRecipes: ['r1', 'r2', 'r4'], // Favourites
        userNotificationsHistory: [],
        userNotificationsEnabled: true,
        userDarkModeEnabled: false,
        userLanguage: 'en',
        userFollowingCount: 10,
        userRecipesCount: 0,
        userFollowersCount: 5,
        userIsChef: false,
        userIsOnFire: false,
        userBio: 'Food lover',
        userSpecialties: [],
        userRecipes: [],
        userDevices: 'device_id',
        userCreationDate: DateTime.now().toIso8601String(),
        userChefDate: '',
      );

      await db.insert('users', user.toMap());
    }
  }

  Future<List<Recipe>> getFavouriteRecipes(String userId) async {
    final db = await _dbHelper.database;

    // Get user
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (userMaps.isEmpty) return [];

    final user = LocalUserModel.fromMap(userMaps.first);
    final favouriteIds = user.userFavouriteRecipes;

    if (favouriteIds.isEmpty) return [];

    // Get recipes
    final List<Map<String, dynamic>> recipeMaps = await db.query(
      'recipes',
      where:
          'recipe_id IN (${List.filled(favouriteIds.length, '?').join(',')})',
      whereArgs: favouriteIds,
    );

    return recipeMaps.map((map) {
      final localRecipe = LocalRecipeModel.fromMap(map);
      return _mapToDomain(localRecipe, true);
    }).toList();
  }

  Future<List<Recipe>> getAllRecipes(String userId) async {
    final db = await _dbHelper.database;

    // Get user to check favourites
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    List<String> favouriteIds = [];
    if (userMaps.isNotEmpty) {
      final user = LocalUserModel.fromMap(userMaps.first);
      favouriteIds = user.userFavouriteRecipes;
    }

    final List<Map<String, dynamic>> recipeMaps = await db.query('recipes');

    return recipeMaps.map((map) {
      final localRecipe = LocalRecipeModel.fromMap(map);
      return _mapToDomain(
        localRecipe,
        favouriteIds.contains(localRecipe.recipeId),
      );
    }).toList();
  }

  Future<Recipe> toggleFavorite(String userId, String recipeId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (userMaps.isEmpty) {
      throw Exception('User not found');
    }

    final user = LocalUserModel.fromMap(userMaps.first);
    List<String> favourites = List.from(user.userFavouriteRecipes);
    bool isFavorite;

    if (favourites.contains(recipeId)) {
      favourites.remove(recipeId);
      isFavorite = false;
    } else {
      favourites.add(recipeId);
      isFavorite = true;
    }

    // Update user
    await db.update(
      'users',
      {'user_favourite_recipes': jsonEncode(favourites)},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Get recipe to return
    final List<Map<String, dynamic>> recipeMaps = await db.query(
      'recipes',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    if (recipeMaps.isEmpty) {
      throw Exception('Recipe not found');
    }

    return _mapToDomain(LocalRecipeModel.fromMap(recipeMaps.first), isFavorite);
  }

  Recipe _mapToDomain(LocalRecipeModel local, bool isFavorite) {
    return Recipe(
      id: local.recipeId,
      title: local.recipeName,
      subtitle: local.recipeDescription,
      imageUrl: local.recipeImageUrl,
      time: '${local.recipePrepTime + local.recipeCookTime} min',
      tags: local.recipeTags,
      isFavorite: isFavorite,
      chefId: local.recipeOwner,
      servings: '${local.recipeServingsCount} servings',
      calories: '${local.recipeCalories} Kcal',
      ingredients: local.recipeIngredients,
      recipeText: local.recipeDescription,
    );
  }
}
