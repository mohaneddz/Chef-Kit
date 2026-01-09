import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'recipe_results_events.dart';
import 'recipe_results_state.dart';

class RecipeResultsBloc extends Bloc<RecipeResultsEvent, RecipeResultsState> {
  final RecipeRepository recipeRepository;
  final FavoritesCacheService _cacheService = FavoritesCacheService();

  RecipeResultsBloc({required this.recipeRepository})
    : super(const RecipeResultsState()) {
    on<LoadRecipeResults>(_onLoad);
    on<SetRecipeResults>(_onSetResults);
    on<ToggleRecipeResultFavorite>(_onToggleFavorite);
  }

  void _onSetResults(SetRecipeResults event, Emitter<RecipeResultsState> emit) {
    emit(state.copyWith(loading: false, matchedRecipes: event.recipes));
  }

  Future<void> _onLoad(
    LoadRecipeResults event,
    Emitter<RecipeResultsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // Use the new endpoint that returns 10 recipes for UI preparation
      final recipes = await recipeRepository.fetchRecipesResult(
        event.selectedIngredients,
      );

      // TODO: Implement actual filtering logic on backend or here once backend is ready
      emit(state.copyWith(loading: false, matchedRecipes: recipes));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleRecipeResultFavorite event,
    Emitter<RecipeResultsState> emit,
  ) async {
    // Optimistic update
    final updatedMatchedRecipes = state.matchedRecipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    emit(state.copyWith(matchedRecipes: updatedMatchedRecipes));

    // Save to local cache immediately for persistence
    await _cacheService.toggleFavorite(event.recipeId);

    // Sync to server in background - don't revert on failure
    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);
      emit(
        state.copyWith(
          matchedRecipes: state.matchedRecipes
              .map((r) => r.id == updated.id ? updated : r)
              .toList(),
        ),
      );
    } catch (e) {
      // Don't revert - keep optimistic state, just show sync error via snackbar
      print('⚠️ Favorite sync failed: $e');
      emit(
        state.copyWith(syncError: 'Failed to sync favorite. Will retry later.'),
      );
    }
  }
}
