import '../../domain/models/recipe.dart';

class FavouritesState {
  final bool loading;
  final List<Map<String, dynamic>> categories;
  final int selectedCategoryIndex;
  final List<Recipe> displayRecipes;
  final String? error;
  final String searchQuery;

  final String? syncError;

  FavouritesState({
    this.loading = false,
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.displayRecipes = const [],
    this.error,
    this.searchQuery = '',
    this.syncError,
  });

  FavouritesState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? categories,
    int? selectedCategoryIndex,
    List<Recipe>? displayRecipes,
    String? error,
    String? searchQuery,
    String? syncError,
  }) => FavouritesState(
    loading: loading ?? this.loading,
    categories: categories ?? this.categories,
    selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
    displayRecipes: displayRecipes ?? this.displayRecipes,
    error: error,
    searchQuery: searchQuery ?? this.searchQuery,
    syncError: syncError,
  );
}
