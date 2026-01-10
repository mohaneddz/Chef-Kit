import 'package:mocktail/mocktail.dart';
import 'package:chefkit/domain/repositories/chef_repository.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
import 'package:chefkit/domain/repositories/profile_repository.dart';
import 'package:chefkit/domain/models/chef.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/domain/models/user_profile.dart';

// ============================================================
// Mock Repositories
// ============================================================

class MockChefRepository extends Mock implements ChefRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

// ============================================================
// Test Data Factories
// ============================================================

Chef createTestChef({
  String id = 'chef-1',
  String name = 'Test Chef',
  String imageUrl = 'https://example.com/chef.jpg',
  String? bio = 'A great chef',
  bool isOnFire = true,
  bool isChef = true,
  int followersCount = 100,
  int recipesCount = 25,
}) {
  return Chef(
    id: id,
    name: name,
    imageUrl: imageUrl,
    bio: bio,
    isOnFire: isOnFire,
    isChef: isChef,
    followersCount: followersCount,
    recipesCount: recipesCount,
  );
}

Recipe createTestRecipe({
  String id = 'recipe-1',
  String name = 'Test Recipe',
  String description = 'A delicious test recipe',
  String imageUrl = 'https://example.com/recipe.jpg',
  String ownerId = 'owner-1',
  int prepTime = 15,
  int cookTime = 30,
  bool isFavorite = false,
  bool isTrending = false,
  bool isSeasonal = false,
}) {
  return Recipe(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    ownerId: ownerId,
    prepTime: prepTime,
    cookTime: cookTime,
    isFavorite: isFavorite,
    isTrending: isTrending,
    isSeasonal: isSeasonal,
    instructions: ['Step 1', 'Step 2'],
    ingredients: ['Ingredient 1', 'Ingredient 2'],
  );
}

UserProfile createTestUserProfile({
  String id = 'user-1',
  String name = 'Test User',
  String email = 'test@example.com',
  String avatarUrl = 'https://example.com/avatar.jpg',
  int recipesCount = 10,
  int followingCount = 20,
  int followersCount = 30,
  bool isChef = false,
  String? bio,
  String? story,
}) {
  return UserProfile(
    id: id,
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    recipesCount: recipesCount,
    followingCount: followingCount,
    followersCount: followersCount,
    isChef: isChef,
    bio: bio,
    story: story,
  );
}
