abstract class FavouritesEvent {}

class LoadFavourites extends FavouritesEvent {
  final String? allSavedText;
  final String? recipeText;
  final String? recipesText;
  final String locale;
  final String? otherText;

  LoadFavourites({
    this.allSavedText,
    this.recipeText,
    this.recipesText,
    this.locale = 'en',
    this.otherText,
  });
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
