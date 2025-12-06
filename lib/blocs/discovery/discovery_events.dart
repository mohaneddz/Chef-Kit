abstract class DiscoveryEvent {}

class LoadDiscovery extends DiscoveryEvent {}

/// Force refresh - reloads even if data exists
class RefreshDiscovery extends DiscoveryEvent {}

class ToggleDiscoveryRecipeFavorite extends DiscoveryEvent {
  final String recipeId;
  ToggleDiscoveryRecipeFavorite(this.recipeId);
}
