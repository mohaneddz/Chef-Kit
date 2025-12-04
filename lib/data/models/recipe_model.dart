import 'dart:convert';

class LocalRecipeModel {
  final String recipeId;
  final String recipeName;
  final String recipeDescription;
  final String recipeImageUrl;
  final String recipeOwner;
  final int recipeServingsCount;
  final int recipePrepTime;
  final int recipeCookTime;
  final int recipeCalories;
  final List<String> recipeIngredients;
  final List<String> recipeItems;
  final List<String> recipeTags;
  final List<String> recipeExternalSources;

  LocalRecipeModel({
    required this.recipeId,
    required this.recipeName,
    required this.recipeDescription,
    required this.recipeImageUrl,
    required this.recipeOwner,
    required this.recipeServingsCount,
    required this.recipePrepTime,
    required this.recipeCookTime,
    required this.recipeCalories,
    required this.recipeIngredients,
    required this.recipeItems,
    required this.recipeTags,
    required this.recipeExternalSources,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'recipe_description': recipeDescription,
      'recipe_image_url': recipeImageUrl,
      'recipe_owner': recipeOwner,
      'recipe_servings_count': recipeServingsCount,
      'recipe_prep_time': recipePrepTime,
      'recipe_cook_time': recipeCookTime,
      'recipe_calories': recipeCalories,
      'recipe_ingredients': jsonEncode(recipeIngredients),
      'recipe_items': jsonEncode(recipeItems),
      'recipe_tags': jsonEncode(recipeTags),
      'recipe_external_sources': jsonEncode(recipeExternalSources),
    };
  }

  factory LocalRecipeModel.fromMap(Map<String, dynamic> map) {
    return LocalRecipeModel(
      recipeId: map['recipe_id'],
      recipeName: map['recipe_name'],
      recipeDescription: map['recipe_description'],
      recipeImageUrl: map['recipe_image_url'],
      recipeOwner: map['recipe_owner'],
      recipeServingsCount: map['recipe_servings_count'],
      recipePrepTime: map['recipe_prep_time'],
      recipeCookTime: map['recipe_cook_time'],
      recipeCalories: map['recipe_calories'],
      recipeIngredients: List<String>.from(
        jsonDecode(map['recipe_ingredients']),
      ),
      recipeItems: List<String>.from(jsonDecode(map['recipe_items'])),
      recipeTags: List<String>.from(jsonDecode(map['recipe_tags'])),
      recipeExternalSources: List<String>.from(
        jsonDecode(map['recipe_external_sources']),
      ),
    );
  }
}
