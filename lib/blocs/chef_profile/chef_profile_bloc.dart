import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'chef_profile_events.dart';
import 'chef_profile_state.dart';

class ChefProfileBloc extends Bloc<ChefProfileEvents, ChefProfileState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;
  ChefProfileBloc({
    required this.chefRepository,
    required this.recipeRepository,
  }) : super(ChefProfileState()) {
    on<LoadChefProfileEvent>(_onLoad);
    on<ToggleChefFollowEvent>(_onToggleFollow);
    on<ToggleChefRecipeFavoriteEvent>(_onToggleRecipeFavorite);
  }

  Future<void> _onLoad(
    LoadChefProfileEvent event,
    Emitter<ChefProfileState> emit,
  ) async {
    print('\n🔵 ChefProfileBloc._onLoad START');
    print('Chef ID: ${event.chefId}');
    print('Access Token: ${event.accessToken != null ? "PROVIDED" : "NULL"}');
    emit(state.copyWith(loading: true, error: null));

    try {
      print('Fetching chef data with auth...');
      final chef = await chefRepository.getChefById(
        event.chefId,
        accessToken: event.accessToken,
      );
      print(
        '✅ Chef loaded: ${chef?.name ?? "null"}, isFollowed: ${chef?.isFollowed}',
      );

      print('Fetching recipes...');
      final recipes = await recipeRepository.fetchRecipesByChef(event.chefId);
      print('✅ Recipes loaded: ${recipes.length} recipes');

      print('Emitting new state...');
      emit(state.copyWith(loading: false, chef: chef, recipes: recipes));
      print('✅ State emitted successfully');
      print('🔵 ChefProfileBloc._onLoad END\n');
    } catch (e, stackTrace) {
      print('\n❌ ERROR in ChefProfileBloc._onLoad: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(loading: false, error: e.toString()));
      print('🔵 ChefProfileBloc._onLoad END (ERROR)\n');
    }
  }

  Future<void> _onToggleFollow(
    ToggleChefFollowEvent event,
    Emitter<ChefProfileState> emit,
  ) async {
    print('\n🟡 ChefProfileBloc._onToggleFollow START');
    print('Chef ID: ${event.chefId}');
    print('Access Token: ${event.accessToken != null ? "PROVIDED" : "NULL"}');

    try {
      print('Calling chefRepository.toggleFollow...');
      final updated = await chefRepository.toggleFollow(
        event.chefId,
        accessToken: event.accessToken,
      );
      print('✅ Toggle follow successful');
      print('New follow status: ${updated.isFollowed}');
      print('New follower count: ${updated.followersCount}');

      emit(state.copyWith(chef: updated));
      print('✅ State updated with new chef data');
      print('🟡 ChefProfileBloc._onToggleFollow END\n');
    } catch (e, stackTrace) {
      print('\n❌ ERROR in ChefProfileBloc._onToggleFollow: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(error: e.toString()));
      print('🟡 ChefProfileBloc._onToggleFollow END (ERROR)\n');
    }
  }

  Future<void> _onToggleRecipeFavorite(
    ToggleChefRecipeFavoriteEvent event,
    Emitter<ChefProfileState> emit,
  ) async {
    final previousState = state;

    // Optimistic update
    final updatedRecipes = state.recipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    emit(state.copyWith(recipes: updatedRecipes));

    try {
      final updated = await recipeRepository.toggleFavorite(event.recipeId);
      emit(
        state.copyWith(
          recipes: state.recipes
              .map((r) => r.id == updated.id ? updated : r)
              .toList(),
        ),
      );
    } catch (e) {
      emit(previousState.copyWith(error: e.toString()));
    }
  }
}
