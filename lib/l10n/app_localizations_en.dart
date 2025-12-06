// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chef Kit';

  @override
  String get discoverRecipes => 'Discover Recipes';

  @override
  String get findYourNextFavoriteMeal => 'Find your next favorite meal';

  @override
  String get searchRecipesOrChefs => 'Search Recipes or Chefs';

  @override
  String get chefs => 'Chefs';

  @override
  String get hotRecipes => 'Hot Recipes';

  @override
  String get seasonalDelights => 'Seasonal Delights';

  @override
  String get seeAll => 'See all';

  @override
  String servings(String count) {
    return '$count servings';
  }

  @override
  String calories(String count) {
    return '$count Kcal';
  }

  @override
  String recipeDetailsFor(String name) {
    return 'Recipe details for $name';
  }

  @override
  String minutes(String count) {
    return '$count min';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get allChefs => 'All Chefs';

  @override
  String get superHot => 'Super Hot';

  @override
  String get total => 'Total';

  @override
  String get superHotChefs => 'Super Hot Chefs';

  @override
  String get trendingChefsSubtitle => 'The most trending chefs right now';

  @override
  String paginationInfo(int currentPage, int totalPages, int chefCount) {
    return 'Page $currentPage of $totalPages • $chefCount chefs';
  }

  @override
  String get recipesStat => 'recipes';

  @override
  String get trendingStat => 'trending';

  @override
  String get favoritesStat => 'favorites';

  @override
  String get filterAll => 'All';

  @override
  String get filterTrending => 'Trending';

  @override
  String get filterTraditional => 'Traditional';

  @override
  String get filterSoup => 'Soup';

  @override
  String get filterQuick => 'Quick';

  @override
  String get hotBadge => 'HOT';

  @override
  String get seasonalDelightsTitle => 'Seasonal Delights';

  @override
  String get freshThisSeason => 'Fresh This Season';

  @override
  String get seasonalDescription =>
      'Discover recipes perfect for the current season';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  @override
  String seasonalRecipesCount(int count, String season) {
    return '$count $season recipes';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationNewRecipeTitle => 'New Recipe Posted!';

  @override
  String get notificationNewRecipeMessage =>
      'Chef Gordon posted a new Beef Wellington recipe';

  @override
  String get notificationRecipeLikedTitle => 'Recipe Liked';

  @override
  String get notificationRecipeLikedMessage =>
      'Sarah liked your Mahjouba recipe';

  @override
  String get notificationNewFollowerTitle => 'New Follower';

  @override
  String get notificationNewFollowerMessage =>
      'Chef Jamie started following you';

  @override
  String get notificationCommentTitle => 'Comment on Recipe';

  @override
  String get notificationCommentMessage =>
      'Mike commented on your Couscous recipe: \"Looks delicious!\"';

  @override
  String get notificationChallengeTitle => 'Weekly Challenge';

  @override
  String get notificationChallengeMessage =>
      'New weekly cooking challenge is now available!';

  @override
  String get notificationSavedTitle => 'Recipe Saved';

  @override
  String get notificationSavedMessage =>
      'Your Tajine recipe was saved by 15 people this week';

  @override
  String get notificationTrendingTitle => 'Trending Recipe';

  @override
  String get notificationTrendingMessage =>
      'Your Chorba recipe is trending! 🔥';

  @override
  String get notificationAchievementTitle => 'New Achievement';

  @override
  String get notificationAchievementMessage =>
      'Congratulations! You unlocked \"Master Chef\" badge';

  @override
  String get notificationRecipeDayTitle => 'Recipe of the Day';

  @override
  String get notificationRecipeDayMessage =>
      'Your Barkoukes was featured as Recipe of the Day!';

  @override
  String get notificationIngredientTitle => 'Ingredient Alert';

  @override
  String get notificationIngredientMessage =>
      'Paprika is running low in your inventory';

  @override
  String timeMinAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHourAgo(int count) {
    return '$count hour ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String timeDayAgo(int count) {
    return '$count day ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get inventoryTitle => 'My Kitchen Inventory';

  @override
  String get inventorySubtitle => 'Manage your ingredients';

  @override
  String get availableIngredientsTitle => 'Available Ingredients';

  @override
  String get availableIngredientsSubtitle => 'Your current pantry items';

  @override
  String availableCount(int count) {
    return '$count Available';
  }

  @override
  String totalItemsCount(int count) {
    return '$count Total Items';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get showMore => 'Show more';

  @override
  String get browseIngredientsTitle => 'Browse all the ingredients';

  @override
  String get browseIngredientsSubtitle => 'Find what you need?';

  @override
  String get ingredientTypeAll => 'All';

  @override
  String get ingredientTypeProtein => 'Protein';

  @override
  String get ingredientTypeVegetables => 'Vegetables';

  @override
  String get ingredientTypeSpices => 'Spices';

  @override
  String get ingredientTypeFruits => 'Fruits';

  @override
  String get favouritesTitle => 'Favourites';

  @override
  String get favouritesSubtitle => 'Find Your Saved Recipes';

  @override
  String get noFavouritesYet => 'No Favourites Yet';

  @override
  String get noFavouritesMessage =>
      'Explore the app and save your favourite recipes!';

  @override
  String get searchYourRecipes => 'Search Your Recipes...';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get searchIngredient => 'Search ingredient...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get retry => 'Retry';

  @override
  String get noProfileData => 'No profile data';

  @override
  String get recipesCount => 'Recipes';

  @override
  String get followingCount => 'Following';

  @override
  String get followersCount => 'Followers';

  @override
  String get chefsCorner => 'Chef\'s Corner';

  @override
  String get myRecipes => 'My Recipes';

  @override
  String get general => 'General';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get security => 'Security';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get logOut => 'Log Out';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String get securityTitle => 'Security';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get accountSecuritySubtitle =>
      'Manage how you sign in and keep your account protected.';

  @override
  String get changeEmail => 'Change email';

  @override
  String get changeEmailSubtitle =>
      'We will send a six-digit code to your new address to confirm the switch.';

  @override
  String get newEmailAddress => 'New email address';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get sendCode => 'Send code';

  @override
  String get confirmChange => 'Confirm change';

  @override
  String get editEmailInput => 'Edit email input';

  @override
  String get updatePassword => 'Update password';

  @override
  String get updatePasswordSubtitle =>
      'Your password must include at least eight characters. We will confirm with a code sent to your inbox.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordHelperText => 'Use at least 8 characters';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get editPasswordInputs => 'Edit password inputs';

  @override
  String get noEmailOnFile => 'No email on file';

  @override
  String get enterNewEmail => 'Please enter a new email address.';

  @override
  String get enterValidEmail => 'Enter a valid email address.';

  @override
  String get emailMatchesCurrent => 'New email matches your current email.';

  @override
  String otpSentTo(String email) {
    return 'OTP sent to $email. Check your inbox to continue.';
  }

  @override
  String get enterOtpSent => 'Enter the OTP code sent to your new email.';

  @override
  String get otpLengthError => 'OTP codes are 6 digits.';

  @override
  String get emailUpdatedSuccess => 'Email updated successfully.';

  @override
  String get completePasswordFields => 'Complete all password fields.';

  @override
  String get passwordLengthError =>
      'Use at least 8 characters for your new password.';

  @override
  String get passwordsDoNotMatch =>
      'New password and confirmation do not match.';

  @override
  String get passwordMustDiffer =>
      'New password must differ from the current password.';

  @override
  String get otpSentEmail =>
      'OTP sent to your email. Enter it to confirm the password update.';

  @override
  String get provideOtpAndPassword =>
      'Provide both the OTP code and new password.';

  @override
  String get passwordUpdatedSuccess =>
      'Password updated successfully. Use your new password next time you sign in.';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get navDiscovery => 'Discovery';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navFavorite => 'Favorite';

  @override
  String get navProfile => 'Profile';

  @override
  String get allSaved => 'All Saved';

  @override
  String get recipeSingular => 'recipe';

  @override
  String get recipePlural => 'recipes';

  @override
  String get loadingAnalyzing => 'Analyzing your ingredients...';

  @override
  String get loadingSearching => 'Searching recipes...';

  @override
  String get loadingMatching => 'Matching...';

  @override
  String get loadingFinding => 'Finding perfect recipes...';

  @override
  String get findingRecipes => 'Finding Recipes';

  @override
  String get recipeResultsTitle => 'Recipe Results';

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes found',
      one: '1 recipe found',
      zero: 'No recipes found',
    );
    return '$_temp0';
  }

  @override
  String get yourIngredients => 'Your Ingredients:';

  @override
  String get recipesYouCanMake => 'Recipes You Can Make';

  @override
  String get sortedByMatch => 'Sorted by ingredient match';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get ingredients => 'Ingredients';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get instructions => 'Instructions';

  @override
  String stepsCount(int count) {
    return '$count steps';
  }

  @override
  String get personalInfoTitle => 'Personal Info';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get bioLabel => 'Bio';

  @override
  String get storyLabel => 'Story';

  @override
  String get specialtiesLabel => 'Specialities';

  @override
  String get addSpecialtyHint => 'Add speciality';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get fullNameEmptyError => 'Full Name cannot be empty';

  @override
  String profileUpdateError(String error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get profileUpdateSuccess => 'Personal info updated';
}
