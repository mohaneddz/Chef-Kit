import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'discovery_events.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;
  DiscoveryBloc({required this.chefRepository, required this.recipeRepository}) : super(DiscoveryState()) {
    on<LoadDiscovery>(_onLoad);
    on<ToggleDiscoveryRecipeFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(LoadDiscovery event, Emitter<DiscoveryState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final chefs = await chefRepository.fetchChefsOnFire();
      final hot = await recipeRepository.fetchHotRecipes();
      final seasonal = await recipeRepository.fetchSeasonalRecipes();
      emit(state.copyWith(loading: false, chefsOnFire: chefs, hotRecipes: hot, seasonalRecipes: seasonal));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(ToggleDiscoveryRecipeFavorite event, Emitter<DiscoveryState> emit) async {
    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);
      emit(state.copyWith(
        hotRecipes: state.hotRecipes.map((r) => r.id == updated.id ? updated : r).toList(),
        seasonalRecipes: state.seasonalRecipes.map((r) => r.id == updated.id ? updated : r).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
