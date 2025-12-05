import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recipe/recipe_repo.dart';
import '../../domain/models/recipe.dart';
import 'favourites_events.dart';
import 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final RecipeRepository recipeRepository;

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
      final favoriteRecipes = await recipeRepository.fetchFavoriteRecipes();

      final Map<String, List<Recipe>> grouped = {};
      for (var recipe in favoriteRecipes) {
        if (recipe.tags.isEmpty) {
          grouped.putIfAbsent('Other', () => []).add(recipe);
        } else {
          for (var tag in recipe.tags) {
            final key = tag.isNotEmpty
                ? tag[0].toUpperCase() + tag.substring(1)
                : 'Other';
            grouped.putIfAbsent(key, () => []).add(recipe);
          }
        }
      }

      final categories = <Map<String, dynamic>>[];

      grouped.forEach((key, value) {
        categories.add({
          'title': key,
          'subtitle': _formatSubtitle(value.length),
          'imagePaths': _getPreviewImagePaths(value),
          'recipes': value,
        });
      });

      categories.add({
        'title': "All Saved",
        'subtitle': _formatSubtitle(favoriteRecipes.length),
        'imagePaths': _getPreviewImagePaths(favoriteRecipes),
        'recipes': favoriteRecipes,
      });

      final newIndex = state.selectedCategoryIndex < categories.length
          ? state.selectedCategoryIndex
          : 0;

      emit(
        state.copyWith(
          loading: false,
          categories: categories,
          displayRecipes: categories.isNotEmpty
              ? categories[newIndex]['recipes'] as List<Recipe>
              : [],
          selectedCategoryIndex: newIndex,
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
      final updated = await recipeRepository.toggleFavorite(event.recipeId);

      // Update the recipe in the current lists without removing it
      List<Recipe> updateList(List<Recipe> list) {
        return list.map((r) => r.id == updated.id ? updated : r).toList();
      }

      final newCategories = state.categories.map((cat) {
        final recipes = cat['recipes'] as List<Recipe>;
        return {...cat, 'recipes': updateList(recipes)};
      }).toList();

      emit(
        state.copyWith(
          categories: newCategories,
          displayRecipes:
              newCategories[state.selectedCategoryIndex]['recipes']
                  as List<Recipe>,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  String _formatSubtitle(int count) {
    return "$count ${count == 1 ? 'recipe' : 'recipes'}";
  }

  List<String> _getPreviewImagePaths(List<Recipe> recipeList) {
    return recipeList.map((recipe) => recipe.imageUrl).take(3).toList();
  }
}
