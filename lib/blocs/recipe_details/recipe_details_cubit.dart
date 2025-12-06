import 'package:flutter_bloc/flutter_bloc.dart';
import 'recipe_details_state.dart';

class RecipeDetailsCubit extends Cubit<RecipeDetailsState> {
  RecipeDetailsCubit({bool initialFavorite = false, int initialServings = 4})
      : super(RecipeDetailsState(
          isFavorite: initialFavorite,
          servings: initialServings,
        ));

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
