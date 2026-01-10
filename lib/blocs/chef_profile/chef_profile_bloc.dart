import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/favorites_cache_service.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'chef_profile_events.dart';
import 'chef_profile_state.dart';

class ChefProfileBloc extends Bloc<ChefProfileEvents, ChefProfileState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;
  final FavoritesCacheService _cacheService = FavoritesCacheService();
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
    // print('\n🔵 ChefProfileBloc._onLoad START');
    // print('Chef ID: ${event.chefId}');
    // print('Access Token: ${event.accessToken != null ? "PROVIDED" : "NULL"}');
    emit(state.copyWith(loading: true, error: null));

    try {
      // print('Fetching chef data with auth...');
      final chef = await chefRepository.getChefById(
        event.chefId,
        accessToken: event.accessToken,
      );
      // print(
      // '✅ Chef loaded: ${chef?.name ?? "null"}, isFollowed: ${chef?.isFollowed}',
      // );

      // print('Fetching recipes...');
      final recipes = await recipeRepository.fetchRecipesByChef(event.chefId);
      // print('✅ Recipes loaded: ${recipes.length} recipes');

      // print('Emitting new state...');
      emit(state.copyWith(loading: false, chef: chef, recipes: recipes));
      // print('✅ State emitted successfully');
      // print('🔵 ChefProfileBloc._onLoad END\n');
    } catch (e) {
      // print('\n❌ ERROR in ChefProfileBloc._onLoad: $e');
      // print('Stack trace: $stackTrace');
      emit(state.copyWith(loading: false, error: e.toString()));
      // print('🔵 ChefProfileBloc._onLoad END (ERROR)\n');
    }
  }

  Future<void> _onToggleFollow(
    ToggleChefFollowEvent event,
    Emitter<ChefProfileState> emit,
  ) async {
    final currentChef = state.chef;
    if (currentChef == null) return;

    // Optimistic update
    final newFollowed = !currentChef.isFollowed;
    final newFollowers =
        (currentChef.followersCount + (newFollowed ? 1 : -1)).clamp(0, 1 << 31);
    emit(
      state.copyWith(
        chef: currentChef.copyWith(
          isFollowed: newFollowed,
          followersCount: newFollowers,
        ),
        error: null,
      ),
    );

    try {
      final updated = await chefRepository.toggleFollow(
        event.chefId,
        accessToken: event.accessToken,
      );
      emit(state.copyWith(chef: updated, error: null));
    } catch (e) {
      // Revert to previous state on failure
      emit(state.copyWith(chef: currentChef, error: e.toString()));
    }
  }

  Future<void> _onToggleRecipeFavorite(
    ToggleChefRecipeFavoriteEvent event,
    Emitter<ChefProfileState> emit,
  ) async {
    // Optimistic update
    final updatedRecipes = state.recipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    emit(state.copyWith(recipes: updatedRecipes));

    // Save to local cache immediately for persistence
    try {
      await _cacheService.toggleFavorite(event.recipeId);
    } catch (_) {
      // Local cache failure should not block server sync or UI.
    }

    // Sync to server in background - don't revert on failure
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
      // Don't revert - keep optimistic state, just show sync error via snackbar
      // print('⚠️ Favorite sync failed: $e');
      emit(
        state.copyWith(syncError: 'Failed to sync favorite. Will retry later.'),
      );
    }
  }
}
