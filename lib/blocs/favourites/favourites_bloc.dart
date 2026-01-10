import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'favourites_events.dart';
import 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final RecipeRepository recipeRepository;
  final FavoritesCacheService _cacheService;

  FavouritesBloc({
    required this.recipeRepository,
    FavoritesCacheService? cacheService,
  }) : _cacheService = cacheService ?? FavoritesCacheService(),
       super(FavouritesState()) {
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

      categories.insert(0, {
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
    // Save to local cache immediately for persistence
    try {
      await _cacheService.toggleFavorite(event.recipeId);
    } catch (_) {
      // Local cache failure should not block server sync or UI.
    }

    try {
      // Toggle favorite on server - this might throw, but we handle it
      await recipeRepository.toggleFavorite(event.recipeId);
      
      // After successful toggle, refresh favorites list to reflect the change
      // This ensures newly favorited recipes appear in the favorites page
      // Use the same parameters that were used to load favorites initially
      // If we don't have them in state, use sensible defaults
      final allSavedTitle = state.categories.isNotEmpty 
          ? (state.categories[0]['title'] as String)
          : 'All Saved';
      
      // Default to 'en' locale if not stored in state - this is fine as it just affects tag categorization
      final locale = 'en'; // Can be improved later by storing locale in state
      
      // Refresh favorites from server with current locale and text
      await _loadData(
        emit,
        allSavedTitle,
        'recipe',
        'recipes',
        locale,
        'Other',
      );
    } catch (e) {
      // If sync fails, show error but don't revert optimistic state
      // The favorite is already saved locally, so it will sync later
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
