import '../../database/repositories/ingredients/ingredients_repository.dart';

class RecipeDetailsState {
  final bool loading;
  final String? error;
  final bool isFavorite;
  final int servings;
  final bool showFullRecipe;
  final Map<String, IngredientTranslation> ingredientTranslations;

  RecipeDetailsState({
    this.loading = false,
    this.error,
    this.isFavorite = false,
    this.servings = 4,
    this.showFullRecipe = false,
    this.ingredientTranslations = const {},
  });

  RecipeDetailsState copyWith({
    bool? loading,
    String? error,
    bool? isFavorite,
    int? servings,
    bool? showFullRecipe,
    Map<String, IngredientTranslation>? ingredientTranslations,
  }) {
    return RecipeDetailsState(
      loading: loading ?? this.loading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
      servings: servings ?? this.servings,
      showFullRecipe: showFullRecipe ?? this.showFullRecipe,
      ingredientTranslations:
          ingredientTranslations ?? this.ingredientTranslations,
    );
  }
}
