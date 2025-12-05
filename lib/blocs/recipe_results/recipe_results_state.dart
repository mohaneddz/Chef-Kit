import 'package:equatable/equatable.dart';
import '../../domain/models/recipe.dart';

class RecipeResultsState extends Equatable {
  final bool loading;
  final String? error;
  final List<Recipe> matchedRecipes;

  const RecipeResultsState({
    this.loading = false,
    this.error,
    this.matchedRecipes = const [],
  });

  RecipeResultsState copyWith({
    bool? loading,
    String? error,
    List<Recipe>? matchedRecipes,
  }) {
    return RecipeResultsState(
      loading: loading ?? this.loading,
      error: error,
      matchedRecipes: matchedRecipes ?? this.matchedRecipes,
    );
  }

  @override
  List<Object?> get props => [loading, error, matchedRecipes];
}
