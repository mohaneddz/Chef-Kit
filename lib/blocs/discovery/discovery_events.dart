abstract class DiscoveryEvent {}

class LoadDiscovery extends DiscoveryEvent {}

class ToggleDiscoveryRecipeFavorite extends DiscoveryEvent {
  final String recipeId;
  ToggleDiscoveryRecipeFavorite(this.recipeId);
}
