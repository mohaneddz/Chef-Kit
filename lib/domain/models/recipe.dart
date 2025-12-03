class Recipe {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String time;
  final List<String> tags;
  final bool isFavorite;
  final String chefId; // owner chef
  final String servings;
  final String calories;
  final List<String> ingredients;
  final String recipeText;

  Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.time,
    required this.tags,
    this.isFavorite = false,
    required this.chefId,
    this.servings = '4 servings',
    this.calories = '500 Kcal',
    this.ingredients = const [],
    this.recipeText = 'Recipe details...',
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? time,
    List<String>? tags,
    bool? isFavorite,
    String? chefId,
    String? servings,
    String? calories,
    List<String>? ingredients,
    String? recipeText,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      chefId: chefId ?? this.chefId,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      recipeText: recipeText ?? this.recipeText,
    );
  }
}
