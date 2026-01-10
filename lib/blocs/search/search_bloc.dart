import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chef_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'search_events.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ChefRepository chefRepository;
  final RecipeRepository recipeRepository;

  Timer? _debounce;

  SearchBloc({required this.chefRepository, required this.recipeRepository})
    : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<ClearSearch>(_onClear);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim().toLowerCase();

    // Cancel previous debounce timer
    _debounce?.cancel();

    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(query: event.query, loading: true));

    // Debounce for 300ms
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Always fetch fresh data (no caching) to ensure new recipes are found
      final allChefs = await chefRepository.fetchAllChefs();
      final allRecipes = await recipeRepository.fetchAllRecipes();

      // Filter chefs by name
      final filteredChefs = allChefs.where((chef) {
        return chef.name.toLowerCase().contains(query);
      }).toList();

      // Filter recipes by name
      final filteredRecipes = allRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            recipe.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();

      emit(
        state.copyWith(
          loading: false,
          chefs: filteredChefs,
          recipes: filteredRecipes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(loading: false, error: 'Search failed: ${e.toString()}'),
      );
    }
  }

  void _onClear(ClearSearch event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
