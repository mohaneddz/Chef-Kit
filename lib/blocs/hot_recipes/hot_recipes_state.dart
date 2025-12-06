import '../../domain/models/recipe.dart';

class HotRecipesState {
  final bool loading;
  final List<Recipe> allRecipes;
  final List<Recipe> filteredRecipes;
  final Set<String> availableTags;
  final String selectedTag;
  final String? error;

  const HotRecipesState({
    this.loading = false,
    this.allRecipes = const [],
    this.filteredRecipes = const [],
    this.availableTags = const {},
    this.selectedTag = 'All',
    this.error,
  });

  /// Helper getters for stats
  int get totalCount => allRecipes.length;
  int get trendingCount => allRecipes.where((r) => r.isTrending).length;
  int get favoritesCount => allRecipes.where((r) => r.isFavorite).length;

  HotRecipesState copyWith({
    bool? loading,
    List<Recipe>? allRecipes,
    List<Recipe>? filteredRecipes,
    Set<String>? availableTags,
    String? selectedTag,
    String? error,
  }) {
    return HotRecipesState(
      loading: loading ?? this.loading,
      allRecipes: allRecipes ?? this.allRecipes,
      filteredRecipes: filteredRecipes ?? this.filteredRecipes,
      availableTags: availableTags ?? this.availableTags,
      selectedTag: selectedTag ?? this.selectedTag,
      error: error,
    );
  }
}
