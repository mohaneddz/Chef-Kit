import 'package:chefkit/domain/repositories/ingredients/ingredients_db.dart';

abstract class IngredientsRepo {
  Future<List<Map<String, dynamic>>> getAllIngredients();
  Future<void> insertIngredient(Map<String, dynamic> data);

  static IngredientsRepo? _instance;

  static IngredientsRepo getInstance() {
    _instance ??= IngredientsDB();
    return _instance!;
  }

  Future<void> seedIngredients() async {
    final repo = IngredientsRepo.getInstance();
    final existing = await repo.getAllIngredients();
    if (existing.isNotEmpty) return;
    final list = [
      // Protein
      {"name": "Chicken Breast", "type": "Protein", "image_path": "assets/images/ingredients/chicken_breast.png"},
      {"name": "Ground Beef", "type": "Protein", "image_path": "assets/images/ingredients/ground_beef.png"},
      {"name": "Salmon Fillet", "type": "Protein", "image_path": "assets/images/ingredients/salmon.png"},
      {"name": "Eggs", "type": "Protein", "image_path": "assets/images/ingredients/eggs.png"},
      {"name": "Tofu", "type": "Protein", "image_path": "assets/images/ingredients/tofu.png"},
      {"name": "Escalope", "type": "Protein", "image_path": "assets/images/ingredients/escalope.png"}, 
      
      // Vegetables & Fruits
      {"name": "Tomato", "type": "Vegetables", "image_path": "assets/images/ingredients/tomato.png"},
      {"name": "Potato", "type": "Vegetables", "image_path": "assets/images/ingredients/potato.png"},
      {"name": "Onion", "type": "Vegetables", "image_path": "assets/images/ingredients/onion.png"},
      {"name": "Garlic", "type": "Vegetables", "image_path": "assets/images/ingredients/garlic.png"},
      {"name": "Carrot", "type": "Vegetables", "image_path": "assets/images/ingredients/carrot.png"},
      {"name": "Broccoli", "type": "Vegetables", "image_path": "assets/images/ingredients/broccoli.png"},
      {"name": "Spinach", "type": "Vegetables", "image_path": "assets/images/ingredients/spinach.png"},
      {"name": "Bell Pepper", "type": "Vegetables", "image_path": "assets/images/ingredients/bell_pepper.png"},
      {"name": "Lemon", "type": "Fruits", "image_path": "assets/images/ingredients/lemon.png"},
      {"name": "Avocado", "type": "Fruits", "image_path": "assets/images/ingredients/avocado.png"},
      
      // Spices & Seasoning 
      {"name": "Salt", "type": "Spices", "image_path": "assets/images/ingredients/salt.png"},
      {"name": "Black Pepper", "type": "Spices", "image_path": "assets/images/ingredients/black_pepper.png"},
      {"name": "Paprika", "type": "Spices", "image_path": "assets/images/ingredients/paprika.png"}, 
      {"name": "Cumin", "type": "Spices", "image_path": "assets/images/ingredients/cumin.png"},
      {"name": "Oregano", "type": "Spices", "image_path": "assets/images/ingredients/oregano.png"},
      {"name": "Basil", "type": "Spices", "image_path": "assets/images/ingredients/basil.png"},
      
      // Dairy
      {"name": "Milk", "type": "Dairy", "image_path": "assets/images/ingredients/milk.png"},
      {"name": "Butter", "type": "Dairy", "image_path": "assets/images/ingredients/butter.png"},
      {"name": "Cheddar Cheese", "type": "Dairy", "image_path": "assets/images/ingredients/cheddar.png"},
      {"name": "Olive Oil", "type": "Fats", "image_path": "assets/images/ingredients/olive_oil.png"},
      
      // Grains
      {"name": "Rice", "type": "Grains", "image_path": "assets/images/ingredients/rice.png"},
      {"name": "Pasta", "type": "Grains", "image_path": "assets/images/ingredients/pasta.png"},
      {"name": "Bread", "type": "Grains", "image_path": "assets/images/ingredients/bread.png"},
    ];

    for (var item in list) {
      await repo.insertIngredient(item);
    }
  }

}