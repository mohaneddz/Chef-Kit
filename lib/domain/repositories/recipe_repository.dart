import 'dart:async';
import '../models/recipe.dart';

class RecipeRepository {
  final List<Recipe> _recipes = [
    Recipe(
      id: 'r1',
      title: 'Mahjouba',
      subtitle: 'Authentic Algerian Classic',
      imageUrl: 'assets/images/Mahjouba.jpeg',
      time: '45 min',
      tags: ['hot'],
      chefId: 'c1',
    ),
    Recipe(
      id: 'r2',
      title: 'Couscous',
      subtitle: 'Steamed semolina with veggies',
      imageUrl: 'assets/images/couscous.png',
      time: '120 min',
      tags: ['hot'],
      chefId: 'c2',
    ),
    Recipe(
      id: 'r3',
      title: 'Barkoukes',
      subtitle: 'Traditional Soup',
      imageUrl: 'assets/images/Barkoukes.jpg',
      time: '90 min',
      tags: ['seasonal'],
      chefId: 'c3',
    ),
    Recipe(
      id: 'r4',
      title: 'Escalope',
      subtitle: 'Delicious & Crispy',
      imageUrl: 'assets/images/escalope.png',
      time: '30 min',
      tags: ['hot'],
      chefId: 'c4',
    ),
    Recipe(
      id: 'r5',
      title: 'Strawberry Salad',
      subtitle: 'with Balsamic Glaze',
      imageUrl: 'assets/images/tomato.png',
      time: '15 min',
      tags: ['seasonal'],
      chefId: 'c5',
    ),
  ];

  Future<List<Recipe>> fetchHotRecipes() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _recipes.where((r) => r.tags.contains('hot')).toList();
  }

  Future<List<Recipe>> fetchSeasonalRecipes() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _recipes.where((r) => r.tags.contains('seasonal')).toList();
  }

  Future<List<Recipe>> fetchRecipesByChef(String chefId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _recipes.where((r) => r.chefId == chefId).toList();
  }

  Future<List<Recipe>> fetchAllRecipes() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_recipes);
  }

  Future<Recipe> toggleFavorite(String recipeId) async {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index == -1) throw Exception('Recipe not found');
    final updated = _recipes[index].copyWith(
      isFavorite: !_recipes[index].isFavorite,
    );
    _recipes[index] = updated;
    return updated;
  }
}
