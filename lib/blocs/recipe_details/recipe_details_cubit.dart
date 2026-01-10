import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/ingredients/ingredients_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'recipe_details_state.dart';

class RecipeDetailsCubit extends Cubit<RecipeDetailsState> {
  final IngredientsRepository _ingredientsRepository = IngredientsRepository();
  final FavoritesCacheService _cacheService = FavoritesCacheService();
  final RecipeRepository _recipeRepository;
  final String recipeId;

  RecipeDetailsCubit({
    required this.recipeId,
    required RecipeRepository recipeRepository,
    bool initialFavorite = false,
    int initialServings = 4,
  }) : _recipeRepository = recipeRepository,
       super(
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

  Future<void> toggleFavorite() async {
    // Optimistic update immediately
    final newFavoriteStatus = !state.isFavorite;
    emit(state.copyWith(isFavorite: newFavoriteStatus, syncError: null));

    // Save to local cache immediately for persistence
    try {
      await _cacheService.toggleFavorite(recipeId);
    } catch (_) {
      // Local cache failure should never block the main server sync.
    }

    // If the page was popped while awaiting, don't emit anything else.
    if (isClosed) return;

    // Sync to server in background - don't revert on failure
    try {
      await _recipeRepository.toggleFavorite(recipeId);
      if (isClosed) return;
      // Success - clear any previous sync errors
      emit(state.copyWith(syncError: null));
    } catch (e) {
      if (isClosed) return;
      // Don't revert UI, just show sync error via snackbar
      // The favorite is already saved locally, so it will persist
      // print('⚠️ Favorite sync failed: $e');
      emit(
        state.copyWith(syncError: 'Failed to sync favorite. Will retry later.'),
      );
    }
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
