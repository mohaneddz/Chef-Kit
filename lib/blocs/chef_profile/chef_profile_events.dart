abstract class ChefProfileEvents {}

class LoadChefProfileEvent extends ChefProfileEvents {
  final String chefId;
  LoadChefProfileEvent(this.chefId);
}

class ToggleChefFollowEvent extends ChefProfileEvents {
  final String chefId;
  final String? accessToken;
  ToggleChefFollowEvent(this.chefId, {this.accessToken});
}

class ToggleChefRecipeFavoriteEvent extends ChefProfileEvents {
  final String recipeId;
  ToggleChefRecipeFavoriteEvent(this.recipeId);
}
