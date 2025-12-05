import 'package:equatable/equatable.dart';
import '../../domain/models/recipe.dart';

class MyRecipesState extends Equatable {
  final List<Recipe> recipes;
  final bool loading;
  final String? error;
  final bool isAdding;
  final bool isDeleting;
  final bool isUpdating;

  const MyRecipesState({
    this.recipes = const [],
    this.loading = false,
    this.error,
    this.isAdding = false,
    this.isDeleting = false,
    this.isUpdating = false,
  });

  MyRecipesState copyWith({
    List<Recipe>? recipes,
    bool? loading,
    String? error,
    bool? isAdding,
    bool? isDeleting,
    bool? isUpdating,
  }) {
    return MyRecipesState(
      recipes: recipes ?? this.recipes,
      loading: loading ?? this.loading,
      error: error,
      isAdding: isAdding ?? this.isAdding,
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [recipes, loading, error, isAdding, isDeleting, isUpdating];
}
