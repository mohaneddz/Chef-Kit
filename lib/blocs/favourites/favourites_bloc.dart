import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recipe_repository.dart';
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
      final allRecipes = await recipeRepository.fetchAllRecipes();

      final traditional = allRecipes.take(4).toList();
      final quick = allRecipes.skip(4).toList();

      final categories = [
        {
          'title': "Traditional",
          'subtitle': _formatSubtitle(traditional.length),
          'imagePaths': _getPreviewImagePaths(traditional),
          'recipes': traditional,
        },
        {
          'title': "Quick & Easy",
          'subtitle': _formatSubtitle(quick.length),
          'imagePaths': _getPreviewImagePaths(quick),
          'recipes': quick,
        },
        {
          'title': "All Saved",
          'subtitle': _formatSubtitle(allRecipes.length),
          'imagePaths': _getPreviewImagePaths(allRecipes),
          'recipes': allRecipes,
        },
      ];

      emit(
        state.copyWith(
          loading: false,
          categories: categories,
          displayRecipes:
              categories[state.selectedCategoryIndex]['recipes']
                  as List<Recipe>,
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
