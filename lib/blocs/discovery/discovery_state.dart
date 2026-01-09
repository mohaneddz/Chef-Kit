import '../../domain/models/chef.dart';
import '../../domain/models/recipe.dart';

class DiscoveryState {
  final bool loading;
  final List<Chef> chefsOnFire;
  final List<Recipe> hotRecipes;
  final List<Recipe> seasonalRecipes;
  final String? error;

  /// Non-blocking error for like sync failures - shows snackbar, doesn't revert UI
  final String? syncError;

  DiscoveryState({
    this.loading = false,
    this.chefsOnFire = const [],
    this.hotRecipes = const [],
    this.seasonalRecipes = const [],
    this.error,
    this.syncError,
  });

  DiscoveryState copyWith({
    bool? loading,
    List<Chef>? chefsOnFire,
    List<Recipe>? hotRecipes,
    List<Recipe>? seasonalRecipes,
    String? error,
    String? syncError,
  }) => DiscoveryState(
    loading: loading ?? this.loading,
    chefsOnFire: chefsOnFire ?? this.chefsOnFire,
    hotRecipes: hotRecipes ?? this.hotRecipes,
    seasonalRecipes: seasonalRecipes ?? this.seasonalRecipes,
    error: error,
    syncError: syncError,
  );
}
