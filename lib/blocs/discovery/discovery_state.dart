import '../../domain/models/chef.dart';
import '../../domain/models/recipe.dart';

class DiscoveryState {
  final bool loading;
  final List<Chef> chefsOnFire;
  final List<Recipe> hotRecipes;
  final List<Recipe> seasonalRecipes;
  final String? error;

  DiscoveryState({
    this.loading = false,
    this.chefsOnFire = const [],
    this.hotRecipes = const [],
    this.seasonalRecipes = const [],
    this.error,
  });

  DiscoveryState copyWith({
    bool? loading,
    List<Chef>? chefsOnFire,
    List<Recipe>? hotRecipes,
    List<Recipe>? seasonalRecipes,
    String? error,
  }) => DiscoveryState(
        loading: loading ?? this.loading,
        chefsOnFire: chefsOnFire ?? this.chefsOnFire,
        hotRecipes: hotRecipes ?? this.hotRecipes,
        seasonalRecipes: seasonalRecipes ?? this.seasonalRecipes,
        error: error,
      );
}
