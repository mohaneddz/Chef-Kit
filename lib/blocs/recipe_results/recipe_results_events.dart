import 'package:chefkit/domain/models/recipe.dart';
import 'package:equatable/equatable.dart';

abstract class RecipeResultsEvent extends Equatable {
  const RecipeResultsEvent();

  @override
  List<Object> get props => [];
}

class LoadRecipeResults extends RecipeResultsEvent {
  final List<String> selectedIngredients;

  const LoadRecipeResults(this.selectedIngredients);

  @override
  List<Object> get props => [selectedIngredients];
}

class SetRecipeResults extends RecipeResultsEvent {
  final List<Recipe> recipes;

  const SetRecipeResults(this.recipes);

  @override
  List<Object> get props => [recipes];
}

class ToggleRecipeResultFavorite extends RecipeResultsEvent {
  final String recipeId;

  const ToggleRecipeResultFavorite(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
