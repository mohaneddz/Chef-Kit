import 'package:chefkit/database/db_helper.dart';
import 'package:chefkit/domain/repositories/ingredients/ingredient_repo.dart';

class IngredientsDB extends IngredientsRepo {
  @override
  Future<List<Map<String, dynamic>>> getAllIngredients() async {
    final db = await DBHelper.database;
    return await db.query("ingredients", orderBy: "name_en ASC");
  }

  @override
  Future<void> insertIngredient(Map<String, dynamic> data) async {
    final db = await DBHelper.database;
    await db.insert("ingredients", data);
  }
}
