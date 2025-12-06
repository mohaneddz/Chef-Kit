abstract class HotRecipesEvent {}

/// Load all hot/trending recipes from the backend
class LoadHotRecipes extends HotRecipesEvent {}

/// Filter recipes by a specific tag or "All"
class FilterByTag extends HotRecipesEvent {
  final String tag;
  FilterByTag(this.tag);
}

/// Toggle favorite status for a recipe
class ToggleHotRecipeFavorite extends HotRecipesEvent {
  final String recipeId;
  ToggleHotRecipeFavorite(this.recipeId);
}
