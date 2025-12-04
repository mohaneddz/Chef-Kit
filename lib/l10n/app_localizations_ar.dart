// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شيف كيت';

  @override
  String get discoverRecipes => 'اكتشف الوصفات';

  @override
  String get findYourNextFavoriteMeal => 'اعثر على وجبتك المفضلة التالية';

  @override
  String get searchRecipesOrChefs => 'ابحث عن وصفات أو طهاة';

  @override
  String get chefs => 'الطهاة';

  @override
  String get hotRecipes => 'وصفات ساخنة';

  @override
  String get seasonalDelights => 'المسرات الموسمية';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String servings(String count) {
    return '$count حصص';
  }

  @override
  String calories(String count) {
    return '$count سعرة حرارية';
  }

  @override
  String recipeDetailsFor(String name) {
    return 'تفاصيل الوصفة لـ $name';
  }
}
