import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../../common/token_storage.dart';

class RecipeRepository {
  late final String baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  RecipeRepository() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  Future<List<String>> _getFavoriteIds() async {
    try {
      final headers = await _getHeaders();
      if (!headers.containsKey('Authorization')) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/favorites/ids'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error fetching favorite IDs: $e');
      return [];
    }
  }

  Future<List<Recipe>> _processRecipes(List<Recipe> recipes) async {
    final favIds = await _getFavoriteIds();
    if (favIds.isEmpty) return recipes;

    return recipes.map((r) {
      if (favIds.contains(r.id)) {
        return r.copyWith(isFavorite: true);
      }
      return r;
    }).toList();
  }

  Future<List<Recipe>> fetchHotRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/recipes/trending'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load trending recipes');
  }

  Future<List<Recipe>> fetchSeasonalRecipes() async {
    // TODO: Add seasonal recipe filter to backend
    final response = await http.get(Uri.parse('$baseUrl/api/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data
          .map((json) => Recipe.fromJson(json))
          .where((r) => r.tags.contains('seasonal'))
          .toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load seasonal recipes');
  }

  Future<List<Recipe>> fetchRecipesByChef(String chefId) async {
    print('\n=== fetchRecipesByChef START ===');
    print('Chef ID: $chefId');
    print('URL: $baseUrl/api/chefs/$chefId/recipes');

    try {
      print('Making HTTP request...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/chefs/$chefId/recipes'),
      );
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response body length: ${response.body.length}');
        print('Response body: ${response.body}');

        print('Decoding JSON...');
        final List<dynamic> data = json.decode(response.body);
        print('Number of recipes in response: ${data.length}');

        final recipes = <Recipe>[];

        for (int i = 0; i < data.length; i++) {
          print('\n--- Parsing recipe $i ---');
          final recipeJson = data[i];
          print('Recipe JSON keys: ${recipeJson.keys.toList()}');
          print('Recipe ID: ${recipeJson['recipe_id']}');
          print('Recipe Name: ${recipeJson['recipe_name']}');

          try {
            print('Calling Recipe.fromJson...');
            final recipe = Recipe.fromJson(recipeJson);
            print('Successfully parsed recipe: ${recipe.name}');
            recipes.add(recipe);
          } catch (e, stackTrace) {
            print('❌ ERROR parsing recipe $i: $e');
            print('Recipe data: $recipeJson');
            print('Stack trace: $stackTrace');
            // Skip this recipe and continue with others
          }
        }

        print('\n✅ Total recipes parsed successfully: ${recipes.length}');
        print('=== fetchRecipesByChef END ===\n');
        return _processRecipes(recipes);
      }
      throw Exception('Failed to load chef recipes: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('\n❌ FATAL ERROR in fetchRecipesByChef: $e');
      print('Stack trace: $stackTrace');
      print('=== fetchRecipesByChef END (ERROR) ===\n');
      rethrow;
    }
  }

  Future<List<Recipe>> fetchAllRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load recipes');
  }

  Future<List<Recipe>> fetchFavoriteRecipes() async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization')) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/favorites'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Recipe.fromJson(json).copyWith(isFavorite: true))
          .toList();
    }
    throw Exception('Failed to load favorite recipes');
  }

  Future<Recipe> toggleFavorite(String recipeId) async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization'))
      throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites/$recipeId/toggle'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isFav = data['is_favorite'] as bool;

      final recipeResponse = await http.get(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
      );
      if (recipeResponse.statusCode == 200) {
        final recipeData = json.decode(recipeResponse.body);
        return Recipe.fromJson(recipeData).copyWith(isFavorite: isFav);
      }
    }
    throw Exception('Failed to toggle favorite');
  }
}
