abstract class FavouritesEvent {}

class LoadFavourites extends FavouritesEvent {}

class SelectCategory extends FavouritesEvent {
  final int index;
  SelectCategory(this.index);
}

class ToggleFavoriteRecipe extends FavouritesEvent {
  final String recipeId;
  ToggleFavoriteRecipe(this.recipeId);
}
