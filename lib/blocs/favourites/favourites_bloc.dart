import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'favourites_events.dart';
import 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final RecipeRepository recipeRepository;
  final FavoritesCacheService _cacheService = FavoritesCacheService();

  FavouritesBloc({required this.recipeRepository}) : super(FavouritesState()) {
    on<LoadFavourites>(_onLoad);
    on<SelectCategory>(_onSelectCategory);
    on<ToggleFavoriteRecipe>(_onToggleFavorite);
    on<SearchFavourites>(_onSearch);
    on<RefreshFavourites>(_onRefresh);
  }

  void _onSearch(SearchFavourites event, Emitter<FavouritesState> emit) {
    final currentCategoryRecipes = state.categories.isNotEmpty
        ? state.categories[state.selectedCategoryIndex]['recipes']
              as List<Recipe>
        : <Recipe>[];

    final filteredRecipes = event.query.isEmpty
        ? currentCategoryRecipes
        : currentCategoryRecipes
              .where(
                (recipe) => recipe.name.toLowerCase().contains(
                  event.query.toLowerCase(),
                ),
              )
              .toList();

    emit(
      state.copyWith(searchQuery: event.query, displayRecipes: filteredRecipes),
    );
  }

  Future<void> _onLoad(
    LoadFavourites event,
    Emitter<FavouritesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    await _loadData(
      emit,
      event.allSavedText,
      event.recipeText,
      event.recipesText,
      event.locale,
      event.otherText,
    );
  }

  Future<void> _onRefresh(
    RefreshFavourites event,
    Emitter<FavouritesState> emit,
  ) async {
    // We don't set loading: true because RefreshIndicator shows its own spinner
    await _loadData(
      emit,
      event.allSavedText,
      event.recipeText,
      event.recipesText,
      event.locale,
      event.otherText,
    );
  }

  Future<void> _loadData(
    Emitter<FavouritesState> emit,
    String? allSavedText,
    String? recipeText,
    String? recipesText,
    String locale,
    String? otherText,
  ) async {
    try {
      final favoriteRecipes = await recipeRepository.fetchFavoriteRecipes();
      final allSavedTitle = allSavedText ?? "All Saved";
      final recipeSingular = recipeText ?? "recipe";
      final recipePlural = recipesText ?? "recipes";
      final otherTitle = otherText ?? "Other";

      final Map<String, List<Recipe>> grouped = {};
      for (var recipe in favoriteRecipes) {
        List<String> tagsToUse = recipe.tags;
        if (locale == 'ar' &&
            recipe.tagsAr != null &&
            recipe.tagsAr!.isNotEmpty) {
          tagsToUse = recipe.tagsAr!;
        } else if (locale == 'fr' &&
            recipe.tagsFr != null &&
            recipe.tagsFr!.isNotEmpty) {
          tagsToUse = recipe.tagsFr!;
        }

        if (tagsToUse.isEmpty) {
          grouped.putIfAbsent(otherTitle, () => []).add(recipe);
        } else {
          for (var tag in tagsToUse) {
            final key = tag.isNotEmpty
                ? tag[0].toUpperCase() + tag.substring(1)
                : otherTitle;
            grouped.putIfAbsent(key, () => []).add(recipe);
          }
        }
      }

      final categories = <Map<String, dynamic>>[];

      grouped.forEach((key, value) {
        categories.add({
          'title': key,
          'subtitle': _formatSubtitle(
            value.length,
            recipeSingular,
            recipePlural,
          ),
          'imagePaths': _getPreviewImagePaths(value),
          'recipes': value,
        });
      });

      categories.add({
        'title': allSavedTitle,
        'subtitle': _formatSubtitle(
          favoriteRecipes.length,
          recipeSingular,
          recipePlural,
        ),
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
          searchQuery: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<FavouritesState> emit) {
    if (event.index < 0 || event.index >= state.categories.length) return;

    final categoryRecipes =
        state.categories[event.index]['recipes'] as List<Recipe>;

    final filteredRecipes = state.searchQuery.isEmpty
        ? categoryRecipes
        : categoryRecipes
              .where(
                (recipe) => recipe.name.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                ),
              )
              .toList();

    emit(
      state.copyWith(
        selectedCategoryIndex: event.index,
        displayRecipes: filteredRecipes,
      ),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteRecipe event,
    Emitter<FavouritesState> emit,
  ) async {
    // Optimistic update
    List<Recipe> updateListOptimistic(List<Recipe> list) {
      return list.map((r) {
        if (r.id == event.recipeId) {
          return r.copyWith(isFavorite: !r.isFavorite);
        }
        return r;
      }).toList();
    }

    final optimisticCategories = state.categories.map((cat) {
      final recipes = cat['recipes'] as List<Recipe>;
      return {...cat, 'recipes': updateListOptimistic(recipes)};
    }).toList();

    final optimisticCurrentCategoryRecipes =
        optimisticCategories[state.selectedCategoryIndex]['recipes']
            as List<Recipe>;
    final optimisticFilteredRecipes = state.searchQuery.isEmpty
        ? optimisticCurrentCategoryRecipes
        : optimisticCurrentCategoryRecipes
              .where(
                (recipe) => recipe.name.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                ),
              )
              .toList();

    emit(
      state.copyWith(
        categories: optimisticCategories,
        displayRecipes: optimisticFilteredRecipes,
      ),
    );

    // Save to local cache immediately for instant persistence
    await _cacheService.toggleFavorite(event.recipeId);

    // Sync to server in background - don't revert on failure
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

      final currentCategoryRecipes =
          newCategories[state.selectedCategoryIndex]['recipes'] as List<Recipe>;
      final filteredRecipes = state.searchQuery.isEmpty
          ? currentCategoryRecipes
          : currentCategoryRecipes
                .where(
                  (recipe) => recipe.name.toLowerCase().contains(
                    state.searchQuery.toLowerCase(),
                  ),
                )
                .toList();

      emit(
        state.copyWith(
          categories: newCategories,
          displayRecipes: filteredRecipes,
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

  String _formatSubtitle(int count, String singular, String plural) {
    return "$count ${count == 1 ? singular : plural}";
  }

  List<String> _getPreviewImagePaths(List<Recipe> recipeList) {
    return recipeList.map((recipe) => recipe.imageUrl).take(3).toList();
  }
}
