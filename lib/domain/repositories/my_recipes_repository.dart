import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MyRecipesRepository {
  final String baseUrl;
  final String accessToken;

  MyRecipesRepository({required this.baseUrl, required this.accessToken});

  /// Get all recipes for the current authenticated chef
  Future<List<Recipe>> getMyRecipes() async {
    print('=== getMyRecipes START ===');
    print('URL: $baseUrl/api/user/recipes');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/recipes'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Number of recipes: ${data.length}');

        final recipes = <Recipe>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final recipe = Recipe.fromJson(data[i]);
            recipes.add(recipe);
          } catch (e) {
            print('❌ Failed to parse recipe $i: $e');
          }
        }

        print('✅ Successfully parsed ${recipes.length} recipes');
        return recipes;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in getMyRecipes: $e');
      print(stackTrace);
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
    print('=== createRecipe START ===');
    print('Recipe name: $name');

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

    print('Request body: ${json.encode(body)}');
    print('[createRecipe] Tags being sent: $tags');
    print('[createRecipe] Tags in body: ${body['recipe_tags']}');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recipes'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Recipe created successfully');
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
    } catch (e, stackTrace) {
      print('❌ Error in createRecipe: $e');
      print(stackTrace);
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
    print('=== updateRecipe START ===');
    print('Recipe ID: $recipeId');

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

    print('Request body: ${json.encode(body)}');
    print('[updateRecipe] Tags being sent: $tags');
    print('[updateRecipe] Tags in body: ${body['recipe_tags']}');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Recipe updated successfully');
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
    } catch (e, stackTrace) {
      print('❌ Error in updateRecipe: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    print('=== deleteRecipe START ===');
    print('Recipe ID: $recipeId');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Recipe deleted successfully');
      } else {
        throw Exception(
          'Failed to delete recipe: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error in deleteRecipe: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
