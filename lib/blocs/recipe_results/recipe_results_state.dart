import 'package:equatable/equatable.dart';
import '../../domain/models/recipe.dart';

class RecipeResultsState extends Equatable {
  final bool loading;
  final String? error;
  final List<Recipe> matchedRecipes;

  /// Non-blocking error for like sync failures - shows snackbar, doesn't revert UI
  final String? syncError;

  const RecipeResultsState({
    this.loading = false,
    this.error,
    this.matchedRecipes = const [],
    this.syncError,
  });

  RecipeResultsState copyWith({
    bool? loading,
    String? error,
    List<Recipe>? matchedRecipes,
    String? syncError,
  }) {
    return RecipeResultsState(
      loading: loading ?? this.loading,
      error: error,
      matchedRecipes: matchedRecipes ?? this.matchedRecipes,
      syncError: syncError,
    );
  }

  @override
  List<Object?> get props => [loading, error, matchedRecipes, syncError];
}
