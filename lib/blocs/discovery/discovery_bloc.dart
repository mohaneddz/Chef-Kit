import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'discovery_events.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;
  DiscoveryBloc({required this.chefRepository, required this.recipeRepository})
    : super(DiscoveryState()) {
    on<LoadDiscovery>(_onLoad);
    on<RefreshDiscovery>(_onRefresh);
    on<ToggleDiscoveryRecipeFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadDiscovery event,
    Emitter<DiscoveryState> emit,
  ) async {
    // Skip if already loading
    if (state.loading) {
      print('⏭️ Discovery: Already loading, skipping');
      return;
    }

    // Skip if we already have data (use refresh for forced reload)
    if (state.chefsOnFire.isNotEmpty &&
        state.hotRecipes.isNotEmpty &&
        state.error == null) {
      print('⏭️ Discovery: Already have data, skipping');
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    // Load each section independently - if one fails, others still load
    var chefs = state.chefsOnFire;
    var hot = state.hotRecipes;
    var seasonal = state.seasonalRecipes;
    var hasAnyData = false;
    String? lastError;

    // Load chefs
    try {
      print('📡 Discovery: Loading chefs...');
      chefs = await chefRepository.fetchChefsOnFire();
      print('✅ Discovery: Got ${chefs.length} chefs');
      hasAnyData = true;
    } catch (e) {
      print('❌ Discovery: Chefs failed: $e');
      lastError = e.toString();
    }

    // Load hot recipes
    try {
      print('📡 Discovery: Loading hot recipes...');
      hot = await recipeRepository.fetchHotRecipes();
      print('✅ Discovery: Got ${hot.length} hot recipes');
      hasAnyData = true;
    } catch (e) {
      print('❌ Discovery: Hot recipes failed: $e');
      lastError = e.toString();
    }

    // Load seasonal recipes (often fails due to large data)
    try {
      print('📡 Discovery: Loading seasonal recipes...');
      seasonal = await recipeRepository.fetchSeasonalRecipes();
      print('✅ Discovery: Got ${seasonal.length} seasonal recipes');
      hasAnyData = true;
    } catch (e) {
      print('❌ Discovery: Seasonal recipes failed: $e (non-critical)');
      // Don't set lastError - seasonal failing is OK if we have other data
    }

    // Only show error if we got NO data at all
    if (hasAnyData) {
      emit(
        state.copyWith(
          loading: false,
          chefsOnFire: chefs,
          hotRecipes: hot,
          seasonalRecipes: seasonal,
          error: null,
        ),
      );
      print('✅ Discovery: Load complete!');
    } else {
      emit(
        state.copyWith(
          loading: false,
          error: lastError ?? 'Failed to load data',
        ),
      );
      print('❌ Discovery: All sections failed');
    }
  }

  /// Force refresh - keep old data visible, only replace on success
  Future<void> _onRefresh(
    RefreshDiscovery event,
    Emitter<DiscoveryState> emit,
  ) async {
    // Don't clear data - keep showing old data while loading
    // Don't show loading spinner for refresh (pull-to-refresh has its own)

    try {
      print('🔄 Discovery: Force refreshing...');
      final chefs = await chefRepository.fetchChefsOnFire();
      final hot = await recipeRepository.fetchHotRecipes();
      final seasonal = await recipeRepository.fetchSeasonalRecipes();

      emit(
        state.copyWith(
          loading: false,
          chefsOnFire: chefs,
          hotRecipes: hot,
          seasonalRecipes: seasonal,
          error: null,
        ),
      );
      print('✅ Discovery: Refresh complete!');
    } catch (e) {
      print('❌ Discovery: Refresh failed: $e');
      // If we have existing data, silently fail - don't show error
      if (state.chefsOnFire.isEmpty && state.hotRecipes.isEmpty) {
        emit(state.copyWith(loading: false, error: e.toString()));
      } else {
        // Keep the old data, just stop loading
        print('ℹ️ Discovery: Keeping old data after refresh failure');
      }
    }
  }

  Future<void> _onToggleFavorite(
    ToggleDiscoveryRecipeFavorite event,
    Emitter<DiscoveryState> emit,
  ) async {
    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);
      emit(
        state.copyWith(
          hotRecipes: state.hotRecipes
              .map((r) => r.id == updated.id ? updated : r)
              .toList(),
          seasonalRecipes: state.seasonalRecipes
              .map((r) => r.id == updated.id ? updated : r)
              .toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
