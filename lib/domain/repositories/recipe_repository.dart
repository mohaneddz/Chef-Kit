import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class RecipeRepository {
  late final String baseUrl;

  RecipeRepository() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }
  }

  Future<List<Recipe>> fetchHotRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/recipes/trending'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load trending recipes');
  }

  Future<List<Recipe>> fetchSeasonalRecipes() async {
    // TODO: Add seasonal recipe filter to backend
    final response = await http.get(Uri.parse('$baseUrl/api/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).where((r) => r.tags.contains('seasonal')).toList();
    }
    throw Exception('Failed to load seasonal recipes');
  }

  Future<List<Recipe>> fetchRecipesByChef(String chefId) async {
    print('\n=== fetchRecipesByChef START ===');
    print('Chef ID: $chefId');
    print('URL: $baseUrl/api/chefs/$chefId/recipes');
    
    try {
      print('Making HTTP request...');
      final response = await http.get(Uri.parse('$baseUrl/api/chefs/$chefId/recipes'));
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
            print('Successfully parsed recipe: ${recipe.title}');
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
        return recipes;
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
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Recipe> toggleFavorite(String recipeId) async {
    // TODO: Implement favorite toggle endpoint when backend supports it
    // For now, just simulate the toggle
    final response = await http.get(Uri.parse('$baseUrl/api/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipe = data.firstWhere((r) => r['recipe_id'] == recipeId);
      final parsedRecipe = Recipe.fromJson(recipe);
      return parsedRecipe.copyWith(isFavorite: !parsedRecipe.isFavorite);
    }
    throw Exception('Recipe not found');
  }
}
