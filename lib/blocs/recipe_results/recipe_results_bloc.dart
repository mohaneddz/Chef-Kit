import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recipe/recipe_repo.dart';
import 'recipe_results_events.dart';
import 'recipe_results_state.dart';

class RecipeResultsBloc extends Bloc<RecipeResultsEvent, RecipeResultsState> {
  final RecipeRepository recipeRepository;

  RecipeResultsBloc({required this.recipeRepository})
    : super(const RecipeResultsState()) {
    on<LoadRecipeResults>(_onLoad);
    on<ToggleRecipeResultFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadRecipeResults event,
    Emitter<RecipeResultsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final allRecipes = await recipeRepository.fetchAllRecipes();

      final selected = event.selectedIngredients
          .map((e) => e.toLowerCase())
          .toSet();

      if (selected.isEmpty) {
        emit(state.copyWith(loading: false, matchedRecipes: allRecipes));
        return;
      }

      // Filter recipes that have at least one matching ingredient
      // If no ingredients are in the recipe, we might want to show it if it's a "loose" search,
      // but typically "Recipe Results" implies filtering.
      // However, since our seed data might be sparse, let's include recipes if they match OR if we have very few results.

      // For now, strict matching: must contain at least one ingredient.
      var matched = allRecipes.where((recipe) {
        final recipeIngredients = recipe.ingredients
            .map((e) => e.toLowerCase())
            .toSet();
        return recipeIngredients.any((i) => selected.contains(i));
      }).toList();

      // If no matches found (likely due to missing data), return all recipes for demo purposes
      // so the user sees something.
      if (matched.isEmpty) {
        matched = allRecipes;
      } else {
        // Sort by match count descending
        matched.sort((a, b) {
          final aCount = a.ingredients
              .where((i) => selected.contains(i.toLowerCase()))
              .length;
          final bCount = b.ingredients
              .where((i) => selected.contains(i.toLowerCase()))
              .length;
          return bCount.compareTo(aCount);
        });
      }

      emit(state.copyWith(loading: false, matchedRecipes: matched));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleRecipeResultFavorite event,
    Emitter<RecipeResultsState> emit,
  ) async {
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
      // Handle error silently or emit error state
    }
  }
}
