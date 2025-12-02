import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'chef_profile_events.dart';
import 'chef_profile_state.dart';

class ChefProfileBloc extends Bloc<ChefProfileEvents, ChefProfileState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;
  ChefProfileBloc({required this.chefRepository, required this.recipeRepository}) : super(ChefProfileState()) {
    on<LoadChefProfileEvent>(_onLoad);
    on<ToggleChefFollowEvent>(_onToggleFollow);
    on<ToggleChefRecipeFavoriteEvent>(_onToggleRecipeFavorite);
  }

  Future<void> _onLoad(LoadChefProfileEvent event, Emitter<ChefProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final chef = await chefRepository.getChefById(event.chefId);
      final recipes = await recipeRepository.fetchRecipesByChef(event.chefId);
      emit(state.copyWith(loading: false, chef: chef, recipes: recipes));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFollow(ToggleChefFollowEvent event, Emitter<ChefProfileState> emit) async {
    try {
      final updated = await chefRepository.toggleFollow(event.chefId);
      emit(state.copyWith(chef: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleRecipeFavorite(ToggleChefRecipeFavoriteEvent event, Emitter<ChefProfileState> emit) async {
    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);
      emit(state.copyWith(recipes: state.recipes.map((r) => r.id == updated.id ? updated : r).toList()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
