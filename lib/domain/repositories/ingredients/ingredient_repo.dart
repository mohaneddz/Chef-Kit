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
      
      {
        "name_en": "Sugar",
        "name_fr": "Sucre",
        "name_ar": "سكر",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/sugar.png"
      },
      {
        "name_en": "Brown Sugar",
        "name_fr": "Cassonade",
        "name_ar": "سكر بني",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/brown_sugar.png"
      },
      {
        "name_en": "Powdered Sugar",
        "name_fr": "Sucre glace",
        "name_ar": "سكر بودرة",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/powdered_sugar.png"
      },
      {
        "name_en": "Honey",
        "name_fr": "Miel",
        "name_ar": "عسل",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/honey.png"
      },
      {
        "name_en": "Maple Syrup",
        "name_fr": "Sirop d'érable",
        "name_ar": "شراب القيقب",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/maple_syrup.png"
      },
      {
        "name_en": "Molasses",
        "name_fr": "Mélasse",
        "name_ar": "دبس السكر",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/molasses.png"
      },
      {
        "name_en": "Corn Syrup",
        "name_fr": "Sirop de maïs",
        "name_ar": "شراب الذرة",
        "type_en": "Sugars",
        "type_fr": "Sucres",
        "type_ar": "سكريات",
        "image_path": "assets/images/ingredients/corn_syrup.png"
      },

      {
        "name_en": "Vegetable Oil",
        "name_fr": "Huile végétale",
        "name_ar": "زيت نباتي",
        "type_en": "Fats",
        "type_fr": "Graisses",
        "type_ar": "دهون",
        "image_path": "assets/images/ingredients/vegetable_oil.png"
      },
      {
        "name_en": "Coconut Oil",
        "name_fr": "Huile de noix de coco",
        "name_ar": "زيت جوز الهند",
        "type_en": "Fats",
        "type_fr": "Graisses",
        "type_ar": "دهون",
        "image_path": "assets/images/ingredients/coconut_oil.png"
      },
      {
        "name_en": "Shortening",
        "name_fr": "Shortening",
        "name_ar": "شورتنينغ",
        "type_en": "Fats",
        "type_fr": "Graisses",
        "type_ar": "دهون",
        "image_path": "assets/images/ingredients/shortening.png"
      },
      {
        "name_en": "Margarine",
        "name_fr": "Margarine",
        "name_ar": "مارجرين",
        "type_en": "Fats",
        "type_fr": "Graisses",
        "type_ar": "دهون",
        "image_path": "assets/images/ingredients/margarine.png"
      },

      // Flours & Grains
      {
        "name_en": "All-Purpose Flour",
        "name_fr": "Farine tout usage",
        "name_ar": "طحين متعدد الاستخدامات",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/all_purpose_flour.png"
      },
      {
        "name_en": "Whole Wheat Flour",
        "name_fr": "Farine de blé entier",
        "name_ar": "طحين القمح الكامل",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/whole_wheat_flour.png"
      },
      {
        "name_en": "Cornmeal",
        "name_fr": "Semoule de maïs",
        "name_ar": "دقيق الذرة",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/cornmeal.png"
      },
      {
        "name_en": "Cornstarch",
        "name_fr": "Fécule de maïs",
        "name_ar": "نشا الذرة",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/cornstarch.png"
      },
      {
        "name_en": "Oats",
        "name_fr": "Flocons d'avoine",
        "name_ar": "شوفان",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/oats.png"
      },
      {
        "name_en": "Rolled Oats",
        "name_fr": "Flocons d'avoine à l'ancienne",
        "name_ar": "شوفان مدور",
        "type_en": "Grains",
        "type_fr": "Céréales",
        "type_ar": "حبوب",
        "image_path": "assets/images/ingredients/rolled_oats.png"
      },
      {
        "name_en": "Baking Powder",
        "name_fr": "Levure chimique",
        "name_ar": "مسحوق الخبز",
        "type_en": "Leavening Agents",
        "type_fr": "Agents levant",
        "type_ar": "عوامل تخمير",
        "image_path": "assets/images/ingredients/baking_powder.png"
      },
      {
        "name_en": "Baking Soda",
        "name_fr": "Bicarbonate de soude",
        "name_ar": "بيكربونات الصودا",
        "type_en": "Leavening Agents",
        "type_fr": "Agents levant",
        "type_ar": "عوامل تخمير",
        "image_path": "assets/images/ingredients/baking_soda.png"
      },
      {
        "name_en": "Yeast",
        "name_fr": "Levure",
        "name_ar": "خميرة",
        "type_en": "Leavening Agents",
        "type_fr": "Agents levant",
        "type_ar": "عوامل تخمير",
        "image_path": "assets/images/ingredients/yeast.png"
      },

      // Liquids & Dairy (milk, butter, cheddar already exist)
      {
        "name_en": "Water",
        "name_fr": "Eau",
        "name_ar": "ماء",
        "type_en": "Liquids",
        "type_fr": "Liquides",
        "type_ar": "سوائل",
        "image_path": "assets/images/ingredients/water.png"
      },
      {
        "name_en": "Buttermilk",
        "name_fr": "Babeurre",
        "name_ar": "مصل اللبن",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/buttermilk.png"
      },
      {
        "name_en": "Heavy Cream",
        "name_fr": "Crème épaisse",
        "name_ar": "كريمة ثقيلة",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/heavy_cream.png"
      },
      {
        "name_en": "Yogurt",
        "name_fr": "Yaourt",
        "name_ar": "زبادي",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/yogurt.png"
      },
      {
        "name_en": "Sour Cream",
        "name_fr": "Crème aigre",
        "name_ar": "كريمة حامضة",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/sour_cream.png"
      },
      {
        "name_en": "Cream Cheese",
        "name_fr": "Fromage à la crème",
        "name_ar": "جبنة كريمية",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/cream_cheese.png"
      },
      {
        "name_en": "Half-and-Half",
        "name_fr": "Moitié-moitié",
        "name_ar": "نصف ونصف",
        "type_en": "Dairy",
        "type_fr": "Laitiers",
        "type_ar": "ألبان",
        "image_path": "assets/images/ingredients/half_and_half.png"
      },

      // Eggs (eggs already exist)
      {
        "name_en": "Egg Whites",
        "name_fr": "Blancs d'œufs",
        "name_ar": "بياض البيض",
        "type_en": "Eggs",
        "type_fr": "Œufs",
        "type_ar": "بيض",
        "image_path": "assets/images/ingredients/egg_whites.png"
      },

      // Extracts & Aromatics
      {
        "name_en": "Vanilla Extract",
        "name_fr": "Extrait de vanille",
        "name_ar": "مستخلص الفانيليا",
        "type_en": "Extracts",
        "type_fr": "Extraits",
        "type_ar": "مستخلصات",
        "image_path": "assets/images/ingredients/vanilla_extract.png"
      },
      {
        "name_en": "Almond Extract",
        "name_fr": "Extrait d'amande",
        "name_ar": "مستخلص اللوز",
        "type_en": "Extracts",
        "type_fr": "Extraits",
        "type_ar": "مستخلصات",
        "image_path": "assets/images/ingredients/almond_extract.png"
      },

      // Spices (salt, black pepper, paprika, cumin, oregano, basil already exist)
      {
        "name_en": "Cinnamon",
        "name_fr": "Cannelle",
        "name_ar": "قرفة",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/cinnamon.png"
      },
      {
        "name_en": "Nutmeg",
        "name_fr": "Muscade",
        "name_ar": "جوزة الطيب",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/nutmeg.png"
      },
      {
        "name_en": "Ginger",
        "name_fr": "Gingembre",
        "name_ar": "زنجبيل",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/ginger.png"
      },
      {
        "name_en": "Cayenne Pepper",
        "name_fr": "Poivre de Cayenne",
        "name_ar": "فلفل كايين",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/cayenne_pepper.png"
      },
      {
        "name_en": "Chili Powder",
        "name_fr": "Poudre de chili",
        "name_ar": "مسحوق الفلفل الحار",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/chili_powder.png"
      },
      {
        "name_en": "Apple Pie Spice",
        "name_fr": "Épices pour tarte aux pommes",
        "name_ar": "بهارات فطيرة التفاح",
        "type_en": "Spices",
        "type_fr": "Épices",
        "type_ar": "بهارات",
        "image_path": "assets/images/ingredients/apple_pie_spice.webp"
      },

      // Acids
      {
        "name_en": "Vinegar",
        "name_fr": "Vinaigre",
        "name_ar": "خل",
        "type_en": "Acids",
        "type_fr": "Acides",
        "type_ar": "أحماض",
        "image_path": "assets/images/ingredients/vinegar.avif"
      },
      {
        "name_en": "White Vinegar",
        "name_fr": "Vinaigre blanc",
        "name_ar": "خل أبيض",
        "type_en": "Acids",
        "type_fr": "Acides",
        "type_ar": "أحماض",
        "image_path": "assets/images/ingredients/white_vinegar.png"
      },
      {
        "name_en": "Apple Vinegar",
        "name_fr": "Vinaigre de cidre",
        "name_ar": "خل التفاح",
        "type_en": "Acids",
        "type_fr": "Acides",
        "type_ar": "أحماض",
        "image_path": "assets/images/ingredients/apple_cider_vinegar.png"
      },
      {
        "name_en": "Lemon Juice",
        "name_fr": "Jus de citron",
        "name_ar": "عصير ليمون",
        "type_en": "Acids",
        "type_fr": "Acides",
        "type_ar": "أحماض",
        "image_path": "assets/images/ingredients/lemon_juice.png"
      },
      {
        "name_en": "Lime Juice",
        "name_fr": "Jus de lime",
        "name_ar": "عصير ليم",
        "type_en": "Acids",
        "type_fr": "Acides",
        "type_ar": "أحماض",
        "image_path": "assets/images/ingredients/lime_juice.png"
      },

      // Nuts & Seeds
      {
        "name_en": "Peanut Butter",
        "name_fr": "Beurre de cacahuète",
        "name_ar": "زبدة الفول السوداني",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/peanut_butter.png"
      },
      {
        "name_en": "Almonds",
        "name_fr": "Amandes",
        "name_ar": "لوز",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/almonds.png"
      },
      {
        "name_en": "Walnuts",
        "name_fr": "Noix",
        "name_ar": "جوز",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/walnuts.png"
      },
      {
        "name_en": "Pecans",
        "name_fr": "Pacanes",
        "name_ar": "جوز البقان",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/pecans.png"
      },
      {
        "name_en": "Pistachios",
        "name_fr": "Pistaches",
        "name_ar": "فستق",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/pistachios.png"
      },
      {
        "name_en": "Peanuts",
        "name_fr": "Cacahuètes",
        "name_ar": "فول سوداني",
        "type_en": "Nuts & Seeds",
        "type_fr": "Noix et graines",
        "type_ar": "مكسرات وبذور",
        "image_path": "assets/images/ingredients/peanuts.png"
      },

      // Common Pantry Staples
      {
        "name_en": "Soy Sauce",
        "name_fr": "Sauce soja",
        "name_ar": "صلصة الصويا",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/soy_sauce.png"
      },
      {
        "name_en": "Tomato Paste",
        "name_fr": "Concentré de tomates",
        "name_ar": "معجون الطماطم",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/tomato_paste.png"
      },
      {
        "name_en": "Mustard",
        "name_fr": "Moutarde",
        "name_ar": "خردل",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/mustard.png"
      },
      {
        "name_en": "Mayonnaise",
        "name_fr": "Mayonnaise",
        "name_ar": "مايونيز",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/mayonnaise.png"
      },
      {
        "name_en": "Broth",
        "name_fr": "Bouillon",
        "name_ar": "مرق",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/broth.png"
      },
      {
        "name_en": "Chicken Broth",
        "name_fr": "Bouillon de poulet",
        "name_ar": "مرق الدجاج",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/chicken_broth.png"
      },
      {
        "name_en": "Vegetable Broth",
        "name_fr": "Bouillon de légumes",
        "name_ar": "مرق الخضار",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/vegetable_broth.png"
      },
      {
        "name_en": "Ketchup",
        "name_fr": "Ketchup",
        "name_ar": "كاتشب",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/ketchup.png"
      },
      {
        "name_en": "Worcestershire Sauce",
        "name_fr": "Sauce Worcestershire",
        "name_ar": "صلصة ورسيسترشاير",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/worcestershire_sauce.png"
      },
      {
        "name_en": "Hot Sauce",
        "name_fr": "Sauce piquante",
        "name_ar": "صلصة حارة",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/hot_sauce.png"
      },
      {
        "name_en": "Cocoa Powder",
        "name_fr": "Poudre de cacao",
        "name_ar": "مسحوق الكاكاو",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/cocoa_powder.png"
      },
      {
        "name_en": "Pudding Mix",
        "name_fr": "Mélange pour pudding",
        "name_ar": "خليط البودينغ",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/pudding_mix.png"
      },
      {
        "name_en": "Gelatin",
        "name_fr": "Gélatine",
        "name_ar": "جيلاتين",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/gelatin.png"
      },
      {
        "name_en": "Marshmallows",
        "name_fr": "Guimauves",
        "name_ar": "مارشملو",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/marshmallows.png"
      },
      {
        "name_en": "Chocolate Chips",
        "name_fr": "Pépites de chocolat",
        "name_ar": "رقائق الشوكولاتة",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/chocolate_chips.png"
      },
      {
        "name_en": "Coconut",
        "name_fr": "Noix de coco",
        "name_ar": "جوز الهند",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/coconut.png"
      },
      {
        "name_en": "Raisins",
        "name_fr": "Raisins secs",
        "name_ar": "زبيب",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/raisins.png"
      },
      {
        "name_en": "Cranberries",
        "name_fr": "Canneberges",
        "name_ar": "توت بري",
        "type_en": "Pantry Staples",
        "type_fr": "Articles de garde-manger",
        "type_ar": "مواد غذائية أساسية",
        "image_path": "assets/images/ingredients/cranberries.png"
      },
    ];

    for (var item in list) {
      await repo.insertIngredient(item);
    }
  }


}