import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MyRecipesRepository {
  final String baseUrl;
  final String accessToken;

  MyRecipesRepository({required this.baseUrl, required this.accessToken});

  /// Get all recipes for the current authenticated chef
  Future<List<Recipe>> getMyRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/recipes'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final recipes = <Recipe>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final recipe = Recipe.fromJson(data[i]);
            recipes.add(recipe);
          } catch (e) {
            // Failed to parse recipe
          }
        }

        return recipes;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new recipe
  Future<Recipe> createRecipe({
    required String name,
    required String description,
    String? imageUrl,
    required int servingsCount,
    required int prepTime,
    required int cookTime,
    required int calories,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> tags,
  }) async {
    final body = {
      'recipe_name': name,
      'recipe_description': description,
      'recipe_image_url': imageUrl,
      'recipe_servings_count': servingsCount,
      'recipe_prep_time': prepTime,
      'recipe_cook_time': cookTime,
      'recipe_calories': calories,
      'recipe_ingredients': ingredients,
      'recipe_instructions': instructions,
      'recipe_tags': tags.isEmpty ? null : tags,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recipes'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Handle both List and Map responses from backend
        if (data is List && data.isNotEmpty) {
          return Recipe.fromJson(data[0] as Map<String, dynamic>);
        }
        return Recipe.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to create recipe: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing recipe
  Future<Recipe> updateRecipe({
    required String recipeId,
    required String name,
    required String description,
    String? imageUrl,
    required int servingsCount,
    required int prepTime,
    required int cookTime,
    required int calories,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> tags,
  }) async {
    final body = {
      'recipe_name': name,
      'recipe_description': description,
      'recipe_image_url': imageUrl,
      'recipe_servings_count': servingsCount,
      'recipe_prep_time': prepTime,
      'recipe_cook_time': cookTime,
      'recipe_calories': calories,
      'recipe_ingredients': ingredients,
      'recipe_instructions': instructions,
      'recipe_tags': tags.isEmpty ? null : tags,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle both List and Map responses from backend
        if (data is List && data.isNotEmpty) {
          return Recipe.fromJson(data[0] as Map<String, dynamic>);
        }
        return Recipe.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to update recipe: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Recipe deleted successfully
      } else {
        throw Exception(
          'Failed to delete recipe: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
