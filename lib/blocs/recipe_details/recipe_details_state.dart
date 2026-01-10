import '../../database/repositories/ingredients/ingredients_repository.dart';

class RecipeDetailsState {
  final bool loading;
  final String? error;
  final bool isFavorite;
  final int servings;
  final bool showFullRecipe;
  final Map<String, IngredientTranslation> ingredientTranslations;

  /// Non-blocking error for like sync failures - shows snackbar, doesn't revert UI
  final String? syncError;

  RecipeDetailsState({
    this.loading = false,
    this.error,
    this.isFavorite = false,
    this.servings = 4,
    this.showFullRecipe = false,
    this.ingredientTranslations = const {},
    this.syncError,
  });

  RecipeDetailsState copyWith({
    bool? loading,
    String? error,
    bool? isFavorite,
    int? servings,
    bool? showFullRecipe,
    Map<String, IngredientTranslation>? ingredientTranslations,
    String? syncError,
  }) {
    return RecipeDetailsState(
      loading: loading ?? this.loading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
      servings: servings ?? this.servings,
      showFullRecipe: showFullRecipe ?? this.showFullRecipe,
      ingredientTranslations:
          ingredientTranslations ?? this.ingredientTranslations,
      syncError: syncError,
    );
  }
}
