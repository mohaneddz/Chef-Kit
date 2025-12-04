import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'favourites_events.dart';
import 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final LocalRecipeRepository recipeRepository;
  final String userId = 'u1'; // Hardcoded for now

  FavouritesBloc({required this.recipeRepository}) : super(FavouritesState()) {
    on<LoadFavourites>(_onLoad);
    on<SelectCategory>(_onSelectCategory);
    on<ToggleFavoriteRecipe>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadFavourites event,
    Emitter<FavouritesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await recipeRepository.seedData();
      final favouriteRecipes = await recipeRepository.getFavouriteRecipes(
        userId,
      );

      // Extract all unique tags
      final Set<String> allTags = {};
      for (var recipe in favouriteRecipes) {
        allTags.addAll(recipe.tags);
      }

      final List<Map<String, dynamic>> categories = [];

      // Create a category for each tag
      for (var tag in allTags) {
        if (tag.isEmpty) continue;

        final tagRecipes = favouriteRecipes
            .where((r) => r.tags.contains(tag))
            .toList();

        if (tagRecipes.isNotEmpty) {
          categories.add({
            'title': tag[0].toUpperCase() + tag.substring(1),
            'subtitle': _formatSubtitle(tagRecipes.length),
            'imagePaths': _getPreviewImagePaths(tagRecipes),
            'recipes': tagRecipes,
          });
        }
      }

      // Add "All Saved" category
      categories.add({
        'title': "All Saved",
        'subtitle': _formatSubtitle(favouriteRecipes.length),
        'imagePaths': _getPreviewImagePaths(favouriteRecipes),
        'recipes': favouriteRecipes,
      });

      // Ensure we have at least "All Saved" if no tags found
      if (categories.isEmpty) {
        categories.add({
          'title': "All Saved",
          'subtitle': _formatSubtitle(favouriteRecipes.length),
          'imagePaths': _getPreviewImagePaths(favouriteRecipes),
          'recipes': favouriteRecipes,
        });
      }

      // Handle case where selectedCategoryIndex might be out of bounds after reload
      int newIndex = state.selectedCategoryIndex;
      if (newIndex >= categories.length) {
        newIndex = 0;
      }

      emit(
        state.copyWith(
          loading: false,
          categories: categories,
          selectedCategoryIndex: newIndex,
          displayRecipes: categories[newIndex]['recipes'] as List<Recipe>,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<FavouritesState> emit) {
    if (event.index < 0 || event.index >= state.categories.length) return;
    emit(
      state.copyWith(
        selectedCategoryIndex: event.index,
        displayRecipes:
            state.categories[event.index]['recipes'] as List<Recipe>,
      ),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteRecipe event,
    Emitter<FavouritesState> emit,
  ) async {
    try {
      final updated = await recipeRepository.toggleFavorite(
        userId,
        event.recipeId,
      );

      // If we are in Favourites page, toggling (unfavoriting) should remove it from the list.
      // But if we want to keep it until refresh, we just update the state.
      // However, usually in Favourites page, if you unfavorite, it disappears.

      // Let's reload the favourites to be consistent.
      add(LoadFavourites());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  String _formatSubtitle(int count) {
    return "$count Recipes";
  }

  List<String> _getPreviewImagePaths(List<Recipe> recipes) {
    return recipes.take(3).map((r) => r.imageUrl).toList();
  }
}
