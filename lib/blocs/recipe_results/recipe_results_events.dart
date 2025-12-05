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

class ToggleRecipeResultFavorite extends RecipeResultsEvent {
  final String recipeId;

  const ToggleRecipeResultFavorite(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
