import '../../domain/models/chef.dart';
import '../../domain/models/recipe.dart';

class ChefProfileState {
  final bool loading;
  final Chef? chef;
  final List<Recipe> recipes;
  final String? error;

  ChefProfileState({
    this.loading = false,
    this.chef,
    this.recipes = const [],
    this.error,
  });

  ChefProfileState copyWith({
    bool? loading,
    Chef? chef,
    List<Recipe>? recipes,
    String? error,
  }) {
    return ChefProfileState(
      loading: loading ?? this.loading,
      chef: chef ?? this.chef,
      recipes: recipes ?? this.recipes,
      error: error,
    );
  }
}
