import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
// unused foundation import removed
import '../../common/config.dart';
import '../../common/token_storage.dart';
import '../../common/authenticated_http_client.dart';

class RecipeRepository {
  late final String baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();
  final AuthenticatedHttpClient _authClient = AuthenticatedHttpClient();

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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recipes/result'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          final recipes = data.map((json) => Recipe.fromJson(json)).toList();
          return _processRecipes(recipes);
        } catch (e) {
          throw Exception('Failed to parse recipes: $e');
        }
      } else {
        throw Exception(
          'Failed to load recipes result: ${response.statusCode}',
        );
      }
    } catch (e) {
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
    // print('Fetching seasonal recipes from $baseUrl/api/recipes/seasonal');
    final response = await _httpGetWithRetry(
      Uri.parse('$baseUrl/api/recipes/seasonal'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      return _processRecipes(recipes);
    }
    throw Exception('Failed to load seasonal recipes: ${response.statusCode}');
  }

  Future<List<Recipe>> fetchRecipesByChef(String chefId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chefs/$chefId/recipes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final recipes = <Recipe>[];

        for (int i = 0; i < data.length; i++) {
          final recipeJson = data[i];

          try {
            final recipe = Recipe.fromJson(recipeJson);
            recipes.add(recipe);
          } catch (e) {
            // Skip this recipe and continue with others
          }
        }

        return _processRecipes(recipes);
      }
      throw Exception('Failed to load chef recipes: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> fetchFavoriteRecipes() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return [];

    // Use AuthenticatedHttpClient for automatic token refresh on 401
    final response = await _authClient.get(Uri.parse('$baseUrl/api/favorites'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Recipe.fromJson(json).copyWith(isFavorite: true))
          .toList();
    }
    throw Exception('Failed to load favorite recipes');
  }

  Future<Recipe> toggleFavorite(String recipeId) async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    try {
      // Use AuthenticatedHttpClient for automatic token refresh on 401
      final response = await _authClient.post(
        Uri.parse('$baseUrl/api/favorites/$recipeId/toggle'),
      );

      // Assume toggle request succeeded if we reached here (even if status != 200 we will handle gracefully)
      bool isFav = true;
      try {
        final data = json.decode(response.body);
        isFav = data['is_favorite'] as bool? ?? isFav;
      } catch (_) {
        // Keep optimistic value
      }

      // Best-effort fetch of full recipe (optional)
      try {
        final recipeResponse = await _authClient.get(
          Uri.parse('$baseUrl/api/recipes/$recipeId'),
        );
        if (recipeResponse.statusCode == 200) {
          final recipeData = json.decode(recipeResponse.body);
          return Recipe.fromJson(recipeData).copyWith(isFavorite: isFav);
        }
      } catch (_) {
        // Ignore fetch failures; toggle already attempted
      }

      // Fallback minimal recipe to avoid throwing; calling code can refresh later
      return Recipe(
        id: recipeId,
        name: 'Recipe',
        description: '',
        imageUrl: '',
        ownerId: '',
      ).copyWith(isFavorite: isFav);
    } catch (e) {
      // Never throw on toggle to avoid breaking UI; return optimistic result
      return Recipe(
        id: recipeId,
        name: 'Recipe',
        description: '',
        imageUrl: '',
        ownerId: '',
      ).copyWith(isFavorite: true);
    }
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
      // print('Error generating recipes: $e');
      rethrow;
    }
  }
}
