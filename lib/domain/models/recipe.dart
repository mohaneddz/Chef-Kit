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
  final bool isTrending;
  final bool isSeasonal;
  final List<String> basicIngredients;

  // Localized fields
  final String? titleAr;
  final String? titleFr;
  final List<String>? tagsAr;
  final List<String>? tagsFr;
  final List<String>? instructionsAr;
  final List<String>? instructionsFr;

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
    this.isTrending = false,
    this.isSeasonal = false,
    this.basicIngredients = const [],
    this.titleAr,
    this.titleFr,
    this.tagsAr,
    this.tagsFr,
    this.instructionsAr,
    this.instructionsFr,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      final prepTime = json['recipe_prep_time'];
      final cookTime = json['recipe_cook_time'];

      // Safely parse time values
      int prepMinutes = 0;
      int cookMinutes = 0;

      if (prepTime != null) {
        if (prepTime is int) {
          prepMinutes = prepTime;
        } else if (prepTime is String) {
          prepMinutes = int.tryParse(prepTime) ?? 0;
        }
      }

      if (cookTime != null) {
        if (cookTime is int) {
          cookMinutes = cookTime;
        } else if (cookTime is String) {
          cookMinutes = int.tryParse(cookTime) ?? 0;
        }
      }

      // Safely parse array fields
      final List<String> ingredients = [];
      if (json['recipe_ingredients'] != null) {
        try {
          final rawIngredients = json['recipe_ingredients'];
          if (rawIngredients is List) {
            for (var item in rawIngredients) {
              if (item != null) {
                ingredients.add(item.toString());
              }
            }
          }
        } catch (e) {
          // Error parsing ingredients
        }
      }

      final List<String> instructions = [];
      if (json['recipe_instructions'] != null) {
        try {
          final rawInstructions = json['recipe_instructions'];
          if (rawInstructions is List) {
            for (var item in rawInstructions) {
              if (item != null) {
                instructions.add(item.toString());
              }
            }
          }
        } catch (e) {
          // Error parsing instructions
        }
      }

      final List<String> tags = [];
      if (json['recipe_tags'] != null) {
        try {
          final rawTags = json['recipe_tags'];
          if (rawTags is List) {
            for (var item in rawTags) {
              if (item != null) {
                tags.add(item.toString());
              }
            }
          }
        } catch (e) {
          // Error parsing tags
        }
      }

      // Safely parse servings count
      int servingsCount = 4;
      final rawServings = json['recipe_servings_count'];
      if (rawServings != null) {
        if (rawServings is int) {
          servingsCount = rawServings;
        } else if (rawServings is String) {
          servingsCount = int.tryParse(rawServings) ?? 4;
        }
      }

      // Safely parse calories
      int caloriesCount = 0;
      final rawCalories = json['recipe_calories'];
      if (rawCalories != null) {
        if (rawCalories is int) {
          caloriesCount = rawCalories;
        } else if (rawCalories is String) {
          caloriesCount = int.tryParse(rawCalories) ?? 0;
        }
      }

      final recipe = Recipe(
        id: json['recipe_id']?.toString() ?? '',
        name: json['recipe_name']?.toString() ?? 'Unknown Recipe',
        description: json['recipe_description']?.toString() ?? '',
        imageUrl:
            json['recipe_image_url']?.toString() ??
            'https://via.placeholder.com/400',
        ownerId: json['recipe_owner']?.toString() ?? '',
        servingsCount: servingsCount,
        prepTime: prepMinutes,
        cookTime: cookMinutes,
        calories: caloriesCount,
        tags: tags,
        ingredients: ingredients,
        instructions: instructions,
        externalSources: _parseList(json['recipe_external_sources']),
        isFavorite: (json['is_favourite'] is int)
            ? (json['is_favourite'] == 1)
            : (json['is_favourite'] as bool? ?? false),
        isTrending: json['recipe_is_trending'] == true,
        isSeasonal: json['recipe_is_seasonal'] == true,
        basicIngredients: _parseList(json['basic_ingredients']),
        titleAr: json['title_ar']?.toString(),
        titleFr: json['title_fr']?.toString(),
        tagsAr: _parseList(json['tags_ar']),
        tagsFr: _parseList(json['tags_fr']),
        instructionsAr: _parseList(json['steps_ar']),
        instructionsFr: _parseList(json['steps_fr']),
      );

      return recipe;
    } catch (e) {
      // Error parsing recipe

      // Return a default recipe to prevent crash
      return Recipe(
        id: json['recipe_id']?.toString() ?? 'error',
        name: 'Error Loading Recipe',
        description: 'There was an error loading this recipe',
        imageUrl: 'https://via.placeholder.com/400',
        ownerId: json['recipe_owner']?.toString() ?? '',
      );
    }
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
    bool? isTrending,
    bool? isSeasonal,
    List<String>? basicIngredients,
    String? titleAr,
    String? titleFr,
    List<String>? tagsAr,
    List<String>? tagsFr,
    List<String>? instructionsAr,
    List<String>? instructionsFr,
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
      isTrending: isTrending ?? this.isTrending,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      basicIngredients: basicIngredients ?? this.basicIngredients,
      titleAr: titleAr ?? this.titleAr,
      titleFr: titleFr ?? this.titleFr,
      tagsAr: tagsAr ?? this.tagsAr,
      tagsFr: tagsFr ?? this.tagsFr,
      instructionsAr: instructionsAr ?? this.instructionsAr,
      instructionsFr: instructionsFr ?? this.instructionsFr,
    );
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
