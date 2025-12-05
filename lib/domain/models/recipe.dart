import 'dart:convert';

class Recipe {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String ownerId;
  final int servingsCount;
  final int prepTime;
  final int cookTime;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final List<String> externalSources;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ownerId,
    this.servingsCount = 1,
    this.prepTime = 0,
    this.cookTime = 0,
    this.calories = 0,
    this.ingredients = const [],
    this.instructions = const [],
    this.tags = const [],
    this.externalSources = const [],
    this.isFavorite = false,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? ownerId,
    int? servingsCount,
    int? prepTime,
    int? cookTime,
    int? calories,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? tags,
    List<String>? externalSources,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      servingsCount: servingsCount ?? this.servingsCount,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tags: tags ?? this.tags,
      externalSources: externalSources ?? this.externalSources,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipe_id'] as String,
      name: json['recipe_name'] as String,
      description: json['recipe_description'] as String? ?? '',
      imageUrl: json['recipe_image_url'] as String? ?? '',
      ownerId: json['recipe_owner'] as String? ?? '',
      servingsCount: json['recipe_servings_count'] as int? ?? 1,
      prepTime: json['recipe_prep_time'] as int? ?? 0,
      cookTime: json['recipe_cook_time'] as int? ?? 0,
      calories: json['recipe_calories'] as int? ?? 0,
      ingredients: _parseList(json['recipe_ingredients']),
      instructions: _parseList(json['recipe_instructions']),
      tags: _parseList(json['recipe_tags']),
      externalSources: _parseList(json['recipe_external_sources']),
      isFavorite: (json['is_favourite'] is int)
          ? (json['is_favourite'] == 1)
          : (json['is_favourite'] as bool? ?? false),
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': id,
      'recipe_name': name,
      'recipe_description': description,
      'recipe_image_url': imageUrl,
      'recipe_owner': ownerId,
      'recipe_servings_count': servingsCount,
      'recipe_prep_time': prepTime,
      'recipe_cook_time': cookTime,
      'recipe_calories': calories,
      'recipe_ingredients': ingredients,
      'recipe_instructions': instructions,
      'recipe_tags': tags,
      'recipe_external_sources': externalSources,
      'is_favourite': isFavorite ? 1 : 0,
    };
  }
}
