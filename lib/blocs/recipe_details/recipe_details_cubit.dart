import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/repositories/ingredients/ingredients_repository.dart';
import 'recipe_details_state.dart';

class RecipeDetailsCubit extends Cubit<RecipeDetailsState> {
  final IngredientsRepository _ingredientsRepository = IngredientsRepository();

  RecipeDetailsCubit({bool initialFavorite = false, int initialServings = 4})
    : super(
        RecipeDetailsState(
          isFavorite: initialFavorite,
          servings: initialServings,
        ),
      );

  Future<void> loadIngredientTranslations(
    List<String> ingredients,
    String locale,
  ) async {
    final Map<String, IngredientTranslation> translations = {};
    for (final ingredient in ingredients) {
      final translation = await _ingredientsRepository.getTranslation(
        ingredient,
        locale,
      );
      if (translation != null) {
        translations[ingredient] = translation;
      }
    }
    emit(state.copyWith(ingredientTranslations: translations));
  }

  void toggleFavorite() {
    emit(state.copyWith(isFavorite: !state.isFavorite));
    // TODO: Call API to update favorite status
  }

  void incrementServings() {
    if (state.servings < 12) {
      emit(state.copyWith(servings: state.servings + 1));
    }
  }

  void decrementServings() {
    if (state.servings > 1) {
      emit(state.copyWith(servings: state.servings - 1));
    }
  }

  void toggleRecipeView() {
    emit(state.copyWith(showFullRecipe: !state.showFullRecipe));
  }
}
