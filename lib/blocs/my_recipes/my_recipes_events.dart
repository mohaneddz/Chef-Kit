import 'package:equatable/equatable.dart';

abstract class MyRecipesEvent extends Equatable {
  const MyRecipesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyRecipesEvent extends MyRecipesEvent {
  const LoadMyRecipesEvent();
}

class AddRecipeEvent extends MyRecipesEvent {
  final String name;
  final String description;
  final String? imageUrl;
  final int servingsCount;
  final int prepTime;
  final int cookTime;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;

  const AddRecipeEvent({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.servingsCount,
    required this.prepTime,
    required this.cookTime,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        imageUrl,
        servingsCount,
        prepTime,
        cookTime,
        calories,
        ingredients,
        instructions,
        tags,
      ];
}

class UpdateRecipeEvent extends MyRecipesEvent {
  final String recipeId;
  final String name;
  final String description;
  final String? imageUrl;
  final int servingsCount;
  final int prepTime;
  final int cookTime;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;

  const UpdateRecipeEvent({
    required this.recipeId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.servingsCount,
    required this.prepTime,
    required this.cookTime,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        recipeId,
        name,
        description,
        imageUrl,
        servingsCount,
        prepTime,
        cookTime,
        calories,
        ingredients,
        instructions,
        tags,
      ];
}

class DeleteRecipeEvent extends MyRecipesEvent {
  final String recipeId;

  const DeleteRecipeEvent(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
