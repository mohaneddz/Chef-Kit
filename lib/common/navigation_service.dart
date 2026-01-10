import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chefkit/common/config.dart';
import 'package:chefkit/common/token_storage.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/views/screens/recipe/recipe_details_page.dart';
import 'package:chefkit/views/screens/profile/chef_profile_public_page.dart';
import 'package:chefkit/views/screens/notifications_page.dart';
import 'package:chefkit/views/screens/discovery/all_hot_recipes_page.dart';

/// Navigation service for handling navigation from push notifications.
/// Uses a global navigator key to navigate outside the widget tree.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final TokenStorage _tokenStorage = TokenStorage();

  /// Navigate to a recipe details page by fetching the recipe first.
  static Future<void> navigateToRecipe(String recipeId) async {
    try {
      // print('[NavigationService] Navigating to recipe: $recipeId');

      // Fetch recipe from backend
      final accessToken = await _tokenStorage.readAccessToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/recipes/$recipeId'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recipe = Recipe.fromJson(data);

        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => RecipeDetailsPage(recipe: recipe)),
        );
      } else {
        // print(
          // '[NavigationService] Failed to fetch recipe: ${response.statusCode}',
        // );
        // Fallback to notifications page
        navigateToNotifications();
      }
    } catch (e) {
      // print('[NavigationService] Error navigating to recipe: $e');
      navigateToNotifications();
    }
  }

  /// Navigate to a chef's public profile page.
  static void navigateToChefProfile(String chefId) {
    // print('[NavigationService] Navigating to chef profile: $chefId');
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => ChefProfilePublicPage(chefId: chefId)),
    );
  }

  /// Navigate to the notifications page (default fallback).
  static void navigateToNotifications() {
    // print('[NavigationService] Navigating to notifications page');
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  /// Navigate to the all hot recipes page.
  static void navigateToHotRecipes() {
    // print('[NavigationService] Navigating to hot recipes page');
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const AllHotRecipesPage()),
    );
  }

  /// Handle navigation from notification data.
  /// Called by FirebaseMessagingService when a notification is tapped.
  static Future<void> handleNotificationNavigation(
    Map<String, dynamic> data,
  ) async {
    // print('[NavigationService] Handling notification navigation: $data');

    final type = data['notification_type'] ?? data['type'];
    final recipeId = data['recipe_id'];
    final chefId = data['chef_id'];
    final followerId = data['follower_id'];
    final userId = data['user_id'];

    switch (type) {
      case 'new_recipe':
        // Navigate to the new recipe
        if (recipeId != null) {
          await navigateToRecipe(recipeId);
        } else if (chefId != null) {
          navigateToChefProfile(chefId);
        } else {
          navigateToNotifications();
        }
        break;

      case 'like':
        // Navigate to the liked recipe
        if (recipeId != null) {
          await navigateToRecipe(recipeId);
        } else {
          navigateToNotifications();
        }
        break;

      case 'follow':
        // Navigate to the follower's profile
        if (followerId != null) {
          navigateToChefProfile(followerId);
        } else if (userId != null) {
          navigateToChefProfile(userId);
        } else {
          navigateToNotifications();
        }
        break;

      case 'daily_recipe':
        // Navigate to the daily recommended recipe
        if (recipeId != null) {
          await navigateToRecipe(recipeId);
        } else {
          navigateToNotifications();
        }
        break;

      case 'hot_recipes':
        // Navigate to the all hot recipes page
        navigateToHotRecipes();
        break;

      default:
        // Unknown type, go to notifications
        navigateToNotifications();
    }
  }
}
