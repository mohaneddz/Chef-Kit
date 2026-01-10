import '../../domain/models/chef.dart';
import '../../domain/models/recipe.dart';

class ChefProfileState {
  final bool loading;
  final Chef? chef;
  final List<Recipe> recipes;
  final String? error;

  /// Non-blocking error for like sync failures - shows snackbar, doesn't revert UI
  final String? syncError;

  ChefProfileState({
    this.loading = false,
    this.chef,
    this.recipes = const [],
    this.error,
    this.syncError,
  });

  ChefProfileState copyWith({
    bool? loading,
    Chef? chef,
    List<Recipe>? recipes,
    String? error,
    String? syncError,
  }) {
    return ChefProfileState(
      loading: loading ?? this.loading,
      chef: chef ?? this.chef,
      recipes: recipes ?? this.recipes,
      error: error,
      syncError: syncError,
    );
  }
}
