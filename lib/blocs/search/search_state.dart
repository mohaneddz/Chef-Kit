import 'package:equatable/equatable.dart';
import '../../domain/models/chef.dart';
import '../../domain/models/recipe.dart';

class SearchState extends Equatable {
  final String query;
  final bool loading;
  final List<Chef> chefs;
  final List<Recipe> recipes;
  final String? error;

  const SearchState({
    this.query = '',
    this.loading = false,
    this.chefs = const [],
    this.recipes = const [],
    this.error,
  });

  bool get hasResults => chefs.isNotEmpty || recipes.isNotEmpty;
  bool get isEmpty => query.isNotEmpty && !loading && !hasResults;

  SearchState copyWith({
    String? query,
    bool? loading,
    List<Chef>? chefs,
    List<Recipe>? recipes,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      loading: loading ?? this.loading,
      chefs: chefs ?? this.chefs,
      recipes: recipes ?? this.recipes,
      error: error,
    );
  }

  @override
  List<Object?> get props => [query, loading, chefs, recipes, error];
}
