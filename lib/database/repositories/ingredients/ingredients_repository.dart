import '../../db_helper.dart';

class IngredientTranslation {
  final String matchedEnglishName;
  final String translatedName;

  IngredientTranslation(this.matchedEnglishName, this.translatedName);
}

class IngredientsRepository {
  Future<IngredientTranslation?> getTranslation(
    String ingredientString,
    String locale,
  ) async {
    final db = await DBHelper.database;

    // We try to find an ingredient name in the DB that is contained in the ingredientString.
    // We order by length descending to match the most specific ingredient (e.g. "cake flour" over "flour").
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: '? LIKE "%" || name_en || "%"',
      whereArgs: [ingredientString],
      orderBy: 'LENGTH(name_en) DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final ingredient = maps.first;
      final matchedName = ingredient['name_en'] as String;
      String translated = matchedName;
      if (locale == 'ar') translated = ingredient['name_ar'] as String;
      if (locale == 'fr') translated = ingredient['name_fr'] as String;

      return IngredientTranslation(matchedName, translated);
    }
    return null;
  }
}
