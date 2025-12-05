class Recipe {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String time;
  final List<String> tags;
  final bool isFavorite;
  final bool isTrending;
  final String chefId;
  final String servings;
  final String calories;
  final List<String> ingredients;
  final List<String> instructions;
  final String recipeText;

  Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.time,
    required this.tags,
    this.isFavorite = false,
    this.isTrending = false,
    required this.chefId,
    this.servings = '4 servings',
    this.calories = '500 Kcal',
    this.ingredients = const [],
    this.instructions = const [],
    this.recipeText = 'Recipe details...',
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print('  📦 Recipe.fromJson called');
    print('  JSON keys: ${json.keys.toList()}');
    
    try {
      print('  Parsing time fields...');
      final prepTime = json['recipe_prep_time'];
      final cookTime = json['recipe_cook_time'];
      print('  prep_time: $prepTime (${prepTime.runtimeType})');
      print('  cook_time: $cookTime (${cookTime.runtimeType})');
      
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
      
      final totalMinutes = prepMinutes + cookMinutes;
      print('  ✅ Total time: $totalMinutes min');
      
      // Safely parse array fields
      print('  Parsing ingredients...');
      final List<String> ingredients = [];
      if (json['recipe_ingredients'] != null) {
        print('  recipe_ingredients type: ${json['recipe_ingredients'].runtimeType}');
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
          print('Error parsing ingredients: $e');
        }
      }
      
      print('  ✅ Ingredients parsed: ${ingredients.length} items');
      
      print('  Parsing instructions...');
      final List<String> instructions = [];
      if (json['recipe_instructions'] != null) {
        print('  recipe_instructions type: ${json['recipe_instructions'].runtimeType}');
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
          print('Error parsing instructions: $e');
        }
      }
      
      print('  ✅ Instructions parsed: ${instructions.length} items');
      
      print('  Parsing tags...');
      final List<String> tags = [];
      if (json['recipe_tags'] != null) {
        print('  recipe_tags type: ${json['recipe_tags'].runtimeType}');
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
          print('Error parsing tags: $e');
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
      
      print('  ✅ Tags parsed: ${tags.length} items');
      print('  Constructing Recipe object...');
      
      final recipe = Recipe(
        id: json['recipe_id']?.toString() ?? '',
        title: json['recipe_name']?.toString() ?? 'Unknown Recipe',
        subtitle: json['recipe_description']?.toString() ?? '',
        imageUrl: json['recipe_image_url']?.toString() ?? 'https://via.placeholder.com/400',
        time: totalMinutes > 0 ? '$totalMinutes min' : 'N/A',
        tags: tags,
        isFavorite: false,
        isTrending: json['recipe_is_trending'] == true,
        chefId: json['recipe_owner']?.toString() ?? '',
        servings: '$servingsCount servings',
        calories: '$caloriesCount Kcal',
        ingredients: ingredients,
        instructions: instructions,
        recipeText: instructions.isNotEmpty ? instructions.join('\n\n') : 'Recipe details...',
      );
      
      print('  ✅ Recipe object created: ${recipe.title}');
      return recipe;
    } catch (e, stackTrace) {
      print('\n❌❌❌ CRITICAL ERROR parsing Recipe from JSON ❌❌❌');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('\nFull JSON data:');
      json.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      print('\nStack trace:');
      print(stackTrace);
      
      // Return a default recipe to prevent crash
      return Recipe(
        id: json['recipe_id']?.toString() ?? 'error',
        title: 'Error Loading Recipe',
        subtitle: 'There was an error loading this recipe',
        imageUrl: 'https://via.placeholder.com/400',
        time: 'N/A',
        tags: [],
        chefId: json['recipe_owner']?.toString() ?? '',
      );
    }
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? time,
    List<String>? tags,
    bool? isFavorite,
    bool? isTrending,
    String? chefId,
    String? servings,
    String? calories,
    List<String>? ingredients,
    List<String>? instructions,
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
      isTrending: isTrending ?? this.isTrending,
      chefId: chefId ?? this.chefId,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      recipeText: recipeText ?? this.recipeText,
    );
  }
}
