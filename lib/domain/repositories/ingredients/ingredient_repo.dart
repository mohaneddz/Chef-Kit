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
      {
        "name_en": "Chicken Breast",
        "name_fr": "Poitrine de poulet",
        "name_ar": "صدر دجاج",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/chicken_breast.png"
      },
      {
        "name_en": "Ground Beef",
        "name_fr": "Boeuf haché",
        "name_ar": "لحم بقري مفروم",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/ground_beef.png"
      },
      {
        "name_en": "Salmon Fillet",
        "name_fr": "Filet de saumon",
        "name_ar": "شرائح سلمون",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/salmon.png"
      },
      {
        "name_en": "Eggs",
        "name_fr": "Œufs",
        "name_ar": "بيض",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/eggs.png"
      },
      {
        "name_en": "Tofu",
        "name_fr": "Tofu",
        "name_ar": "توفو",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/tofu.png"
      },
      {
        "name_en": "Escalope",
        "name_fr": "Escalope",
        "name_ar": "إسكالوب",
        "type_en": "Protein",
        "type_fr": "Protéine",
        "type_ar": "بروتين",
        "image_path": "assets/images/ingredients/escalope.png"
      },

      // Vegetables
      {
        "name_en": "Tomato",
        "name_fr": "Tomate",
        "name_ar": "طماطم",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/tomato.png"
      },
      {
        "name_en": "Potato",
        "name_fr": "Pomme de terre",
        "name_ar": "بطاطا",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/potato.png"
      },
      {
        "name_en": "Onion",
        "name_fr": "Oignon",
        "name_ar": "بصل",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/onion.png"
      },
      {
        "name_en": "Garlic",
        "name_fr": "Ail",
        "name_ar": "ثوم",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/garlic.png"
      },
      {
        "name_en": "Carrot",
        "name_fr": "Carotte",
        "name_ar": "جزر",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/carrot.png"
      },
      {
        "name_en": "Broccoli",
        "name_fr": "Brocoli",
        "name_ar": "بروكلي",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/broccoli.png"
      },
      {
        "name_en": "Spinach",
        "name_fr": "Épinards",
        "name_ar": "سبانخ",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/spinach.png"
      },
      {
        "name_en": "Bell Pepper",
        "name_fr": "Poivron",
        "name_ar": "فلفل حلو",
        "type_en": "Vegetables",
        "type_fr": "Légumes",
        "type_ar": "خضروات",
        "image_path": "assets/images/ingredients/bell_pepper.png"
      },

      // Fruits
      {
        "name_en": "Lemon",
        "name_fr": "Citron",
        "name_ar": "ليمون",
        "type_en": "Fruits",
        "type_fr": "Fruits",
        "type_ar": "فواكه",
        "image_path": "assets/images/ingredients/lemon.png"
      },
      {
        "name_en": "Avocado",
        "name_fr": "Avocat",
        "name_ar": "أفوكادو",
        "type_en": "Fruits",
        "type_fr": "Fruits",
        "type_ar": "فواكه",
        "image_path": "assets/images/ingredients/avocado.png"
      },

      // Spices
      {
        "name_en": "Salt",
        "name_fr": "Sel",
        "name_ar": "ملح",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/salt.png"
      },
      {
        "name_en": "Black Pepper",
        "name_fr": "Poivre noir",
        "name_ar": "فلفل أسود",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/black_pepper.png"
      },
      {
        "name_en": "Paprika",
        "name_fr": "Paprika",
        "name_ar": "بابريكا",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/paprika.png"
      },
      {
        "name_en": "Cumin",
        "name_fr": "Cumin",
        "name_ar": "كمون",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/cumin.png"
      },
      {
        "name_en": "Oregano",
        "name_fr": "Origan",
        "name_ar": "أوريغانو",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/oregano.png"
      },
      {
        "name_en": "Basil",
        "name_fr": "Basilic",
        "name_ar": "ريحان",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/basil.png"
      },

      // Dairy
      {
        "name_en": "Milk",
        "name_fr": "Lait",
        "name_ar": "حليب",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/milk.png"
      },
      {
        "name_en": "Butter",
        "name_fr": "Beurre",
        "name_ar": "زبدة",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/butter.png"
      },
      {
        "name_en": "Cheddar Cheese",
        "name_fr": "Fromage cheddar",
        "name_ar": "جبن شيدر",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/cheddar.png"
      },

      // Fats
      {
        "name_en": "Olive Oil",
        "name_fr": "Huile d'olive",
        "name_ar": "زيت زيتون",
        "type_en": "Fats",
        "type_fr": "Graisses",
        "type_ar": "دهون",
        "image_path": "assets/images/ingredients/olive_oil.png"
      },

      // Grains
      {
        "name_en": "Rice",
        "name_fr": "Riz",
        "name_ar": "أرز",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/rice.png"
      },
      {
        "name_en": "Pasta",
        "name_fr": "Pâtes",
        "name_ar": "معكرونة",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/pasta.png"
      },
      {
        "name_en": "Bread",
        "name_fr": "Pain",
        "name_ar": "خبز",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/bread.png"
      },
    ];

    for (var item in list) {
      await repo.insertIngredient(item);
    }
  }


}