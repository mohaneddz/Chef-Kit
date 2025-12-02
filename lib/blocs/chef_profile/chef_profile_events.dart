abstract class ChefProfileEvents {}

class LoadChefProfileEvent extends ChefProfileEvents {
  final String chefId;
  LoadChefProfileEvent(this.chefId);
}

class ToggleChefFollowEvent extends ChefProfileEvents {
  final String chefId;
  ToggleChefFollowEvent(this.chefId);
}

class ToggleChefRecipeFavoriteEvent extends ChefProfileEvents {
  final String recipeId;
  ToggleChefRecipeFavoriteEvent(this.recipeId);
}
