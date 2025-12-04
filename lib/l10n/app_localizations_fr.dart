// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chef Kit';

  @override
  String get discoverRecipes => 'Découvrir des recettes';

  @override
  String get findYourNextFavoriteMeal => 'Trouvez votre prochain repas préféré';

  @override
  String get searchRecipesOrChefs => 'Rechercher des recettes ou des chefs';

  @override
  String get chefs => 'Chefs';

  @override
  String get hotRecipes => 'Recettes populaires';

  @override
  String get seasonalDelights => 'Délices de saison';

  @override
  String get seeAll => 'Tout voir';

  @override
  String servings(String count) {
    return '$count portions';
  }

  @override
  String calories(String count) {
    return '$count Kcal';
  }

  @override
  String recipeDetailsFor(String name) {
    return 'Détails de la recette pour $name';
  }
}
