abstract class FavouritesEvent {}

class LoadFavourites extends FavouritesEvent {
  final String? allSavedText;
  final String? recipeText;
  final String? recipesText;

  LoadFavourites({this.allSavedText, this.recipeText, this.recipesText});
}

class SelectCategory extends FavouritesEvent {
  final int index;
  SelectCategory(this.index);
}

class ToggleFavoriteRecipe extends FavouritesEvent {
  final String recipeId;
  ToggleFavoriteRecipe(this.recipeId);
}

class SearchFavourites extends FavouritesEvent {
  final String query;
  SearchFavourites(this.query);
}
