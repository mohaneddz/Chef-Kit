import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_recipes_events.dart';
import 'my_recipes_state.dart';
import '../../domain/repositories/my_recipes_repository.dart';

class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  final MyRecipesRepository repository;

  MyRecipesBloc({required this.repository}) : super(const MyRecipesState()) {
    on<LoadMyRecipesEvent>(_onLoad);
    on<AddRecipeEvent>(_onAdd);
    on<UpdateRecipeEvent>(_onUpdate);
    on<DeleteRecipeEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadMyRecipesEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // print('🔵 Loading my recipes...');
      final recipes = await repository.getMyRecipes();
      // print('✅ Loaded ${recipes.length} recipes');
      emit(state.copyWith(recipes: recipes, loading: false));
    } catch (e) {
      // print('❌ Error loading my recipes: $e');
      // print(stackTrace);
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onAdd(
    AddRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, error: null));

    try {
      // print('🔵 Adding new recipe: ${event.name}');
      final newRecipe = await repository.createRecipe(
        name: event.name,
        description: event.description,
        imageUrl: event.imageUrl,
        servingsCount: event.servingsCount,
        prepTime: event.prepTime,
        cookTime: event.cookTime,
        calories: event.calories,
        ingredients: event.ingredients,
        instructions: event.instructions,
        tags: event.tags,
      );

      // print('✅ Recipe created: ${newRecipe.id}');

      // Add to the list
      final updatedRecipes = [...state.recipes, newRecipe];
      emit(state.copyWith(recipes: updatedRecipes, isAdding: false));
    } catch (e) {
      // print('❌ Error adding recipe: $e');
      // print(stackTrace);
      emit(state.copyWith(isAdding: false, error: e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, error: null));

    try {
      // print('🔵 Updating recipe: ${event.recipeId}');
      final updatedRecipe = await repository.updateRecipe(
        recipeId: event.recipeId,
        name: event.name,
        description: event.description,
        imageUrl: event.imageUrl,
        servingsCount: event.servingsCount,
        prepTime: event.prepTime,
        cookTime: event.cookTime,
        calories: event.calories,
        ingredients: event.ingredients,
        instructions: event.instructions,
        tags: event.tags,
      );

      // print('✅ Recipe updated: ${updatedRecipe.id}');

      // Update in the list
      final updatedRecipes = state.recipes.map((r) {
        return r.id == event.recipeId ? updatedRecipe : r;
      }).toList();

      emit(state.copyWith(recipes: updatedRecipes, isUpdating: false));
    } catch (e) {
      // print('❌ Error updating recipe: $e');
      // print(stackTrace);
      emit(state.copyWith(isUpdating: false, error: e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, error: null));

    try {
      // print('🔵 Deleting recipe: ${event.recipeId}');
      await repository.deleteRecipe(event.recipeId);
      // print('✅ Recipe deleted: ${event.recipeId}');

      // Remove from the list
      final updatedRecipes = state.recipes
          .where((r) => r.id != event.recipeId)
          .toList();
      emit(state.copyWith(recipes: updatedRecipes, isDeleting: false));
    } catch (e) {
      // print('❌ Error deleting recipe: $e');
      // print(stackTrace);
      emit(state.copyWith(isDeleting: false, error: e.toString()));
    }
  }
}
