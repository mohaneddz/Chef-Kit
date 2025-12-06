import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
// unused foundation import removed
import '../../common/config.dart';
import '../../common/token_storage.dart';

class RecipeRepository {
  late final String baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  RecipeRepository() {
    baseUrl = AppConfig.baseUrl;
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

  /// Helper method to perform HTTP GET with automatic retry on connection errors
  Future<http.Response> _httpGetWithRetry(
    Uri uri, {
    Map<String, String>? headers,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        return await http.get(uri, headers: headers).timeout(timeout);
      } on TimeoutException {
        if (attempts < maxRetries) {
          print(
            '⏱️ HTTP timeout, retry attempt $attempts/$maxRetries for $uri',
          );
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        throw Exception('Connection timed out. Please check your connection.');
      } catch (e) {
        // Check if it's a connection-related error
        final isConnectionError =
            e is SocketException ||
            e.toString().contains('Connection closed') ||
            e.toString().contains('ClientException');

        if (isConnectionError && attempts < maxRetries) {
          print('🔄 HTTP retry attempt $attempts/$maxRetries for $uri');
          await Future.delayed(Duration(milliseconds: 100 * attempts));
          continue;
        }
        rethrow;
      }
    }
  }

  Future<List<String>> _getFavoriteIds() async {
    try {
      final headers = await _getHeaders();
      if (!headers.containsKey('Authorization')) return [];

      final response = await _httpGetWithRetry(
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

  Future<List<Recipe>> fetchAllRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load all recipes');
  }

  Future<List<Recipe>> fetchRecipesResult(List<String> ingredients) async {
    print('Fetching recipes result from: $baseUrl/api/recipes/result');
    print('Ingredients: $ingredients');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recipes/result'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ingredients': ingredients}),
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          print('Decoded JSON data length: ${data.length}');
          final recipes = data.map((json) => Recipe.fromJson(json)).toList();
          print('Parsed ${recipes.length} recipes');
          return _processRecipes(recipes);
        } catch (e, stack) {
          print('Error parsing recipes: $e');
          print(stack);
          throw Exception('Failed to parse recipes: $e');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception(
          'Failed to load recipes result: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Network or other error: $e');
      rethrow;
    }
  }

  Future<List<Recipe>> fetchHotRecipes() async {
    final response = await _httpGetWithRetry(
      Uri.parse('$baseUrl/api/recipes/trending'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load trending recipes');
  }

  Future<List<Recipe>> fetchSeasonalRecipes() async {
    print('Fetching seasonal recipes from $baseUrl/api/recipes/seasonal');
    final response = await _httpGetWithRetry(
      Uri.parse('$baseUrl/api/recipes/seasonal'),
    );
    print('Seasonal response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    print('❌ Seasonal recipes failed with status ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to load seasonal recipes: ${response.statusCode}');
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

  Future<List<Recipe>> fetchFavoriteRecipes() async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization')) return [];

    final response = await _httpGetWithRetry(
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

  Future<List<Recipe>> generateRecipes({
    required String lang,
    required String maxTime,
    required List<String> ingredients,
  }) async {
    final headers = await _getHeaders();
    final body = json.encode({'time': maxTime, 'ingredients': ingredients});

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cook'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipesJson = data['recipes'];
        return recipesJson.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to generate recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating recipes: $e');
      rethrow;
    }
  }
}
