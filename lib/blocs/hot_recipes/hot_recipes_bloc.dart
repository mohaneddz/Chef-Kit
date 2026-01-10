import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'hot_recipes_events.dart';
import 'hot_recipes_state.dart';

class HotRecipesBloc extends Bloc<HotRecipesEvent, HotRecipesState> {
  final RecipeRepository recipeRepository;
  final FavoritesCacheService _cacheService = FavoritesCacheService();

  HotRecipesBloc({required this.recipeRepository})
    : super(const HotRecipesState()) {
    on<LoadHotRecipes>(_onLoad);
    on<FilterByTag>(_onFilterByTag);
    on<ToggleHotRecipeFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadHotRecipes event,
    Emitter<HotRecipesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final recipes = await recipeRepository.fetchHotRecipes();

      // Extract unique tags from all recipes
      final tags = <String>{};
      for (final recipe in recipes) {
        tags.addAll(recipe.tags);
      }

      emit(
        state.copyWith(
          loading: false,
          allRecipes: recipes,
          filteredRecipes: recipes,
          availableTags: tags,
          selectedTag: 'All',
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onFilterByTag(FilterByTag event, Emitter<HotRecipesState> emit) {
    final tag = event.tag;
    List<Recipe> filtered;

    if (tag == 'All') {
      filtered = state.allRecipes;
    } else if (tag == 'Trending') {
      filtered = state.allRecipes.where((r) => r.isTrending).toList();
    } else {
      // Filter by specific tag
      filtered = state.allRecipes.where((r) => r.tags.contains(tag)).toList();
    }

    emit(state.copyWith(selectedTag: tag, filteredRecipes: filtered));
  }

  Future<void> _onToggleFavorite(
    ToggleHotRecipeFavorite event,
    Emitter<HotRecipesState> emit,
  ) async {
    // Optimistic update
    final updatedAllOptimistic = state.allRecipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();
    final updatedFilteredOptimistic = state.filteredRecipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    emit(
      state.copyWith(
        allRecipes: updatedAllOptimistic,
        filteredRecipes: updatedFilteredOptimistic,
      ),
    );

    // Save to local cache immediately for persistence
    await _cacheService.toggleFavorite(event.recipeId);

    // Sync to server in background - don't revert on failure
    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);

      // Update the recipe in both lists
      final updatedAll = state.allRecipes
          .map((r) => r.id == updated.id ? updated : r)
          .toList();
      final updatedFiltered = state.filteredRecipes
          .map((r) => r.id == updated.id ? updated : r)
          .toList();

      emit(
        state.copyWith(
          allRecipes: updatedAll,
          filteredRecipes: updatedFiltered,
        ),
      );
    } catch (e) {
      // Don't revert - keep optimistic state, just show sync error via snackbar
      // print('⚠️ Favorite sync failed: $e');
      emit(
        state.copyWith(syncError: 'Failed to sync favorite. Will retry later.'),
      );
    }
  }
}
