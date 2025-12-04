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
}
