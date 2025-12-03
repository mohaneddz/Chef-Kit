// lib/data/recipe_data.dart

class Recipe {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final int duration; // Duration in minutes
  final bool isReady;
  final String servings;
  final String calories;
  final List<String> ingredients;
  final List<String> tags;
  final String recipeText;
  bool isFavorite; // Not final, so it can be toggled

  Recipe({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.duration,
    required this.isReady,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.tags,
    required this.recipeText,
    this.isFavorite = false,
  });
}

// Dummy data list populated from your old structure
// with new fields added as placeholders.
final List<Recipe> dummyRecipes = [
  Recipe(
    id: '1',
    name: 'Couscous',
    category: 'Traditional',
    duration: 120,
    isReady: true,
    imagePath: 'assets/images/couscous.png',
    servings: '4 servings',
    calories: '650 Kcal',
    ingredients: [
      'Couscous',
      'Chicken',
      'Zucchini',
      'Carrots',
      'Chickpeas',
      'Turnips',
    ],
    tags: ['Traditional', 'Algerian', 'Main Dish'],
    recipeText:
        'A detailed recipe for Couscous. First, prepare the vegetables. Second, cook the meat. Third, steam the couscous grains...',
    isFavorite: true,
  ),
  Recipe(
    id: '2',
    name: 'Hrira',
    category: 'Traditional',
    duration: 60,
    isReady: true,
    imagePath: 'assets/images/Barkoukes.jpg',
    servings: '6 servings',
    calories: '300 Kcal',
    ingredients: [
      'Tomatoes',
      'Lentils',
      'Chickpeas',
      'Meat',
      'Spices',
      'Herbs',
    ],
    tags: ['Traditional', 'Soup', 'Ramadan'],
    recipeText:
        'A detailed recipe for Hrira. Start by browning the meat with onions. Add tomatoes, spices, and legumes. Let it simmer...',
    isFavorite: true,
  ),
  Recipe(
    id: '3',
    name: 'Roqaq',
    category: 'Traditional',
    duration: 120,
    isReady: true,
    imagePath: 'assets/images/Mahjouba.jpeg',
    servings: '5 servings',
    calories: '700 Kcal',
    ingredients: ['Semolina', 'Water', 'Salt', 'Chicken', 'Onion', 'Spices'],
    tags: ['Traditional', 'Savory', 'Baked'],
    recipeText:
        'A detailed recipe for Roqaq. Prepare the thin dough and cook it. Separately, make the chicken and onion sauce...',
    isFavorite: true,
  ),
  Recipe(
    id: '4',
    name: 'Tagine',
    category: 'Traditional',
    duration: 60,
    isReady: false,
    imagePath: 'assets/images/recipes/tagine.png',
    servings: '3 servings',
    calories: '550 Kcal',
    ingredients: ['Lamb', 'Prunes', 'Almonds', 'Onions', 'Saffron', 'Ginger'],
    tags: ['Traditional', 'Sweet & Savory', 'Slow-cooked'],
    recipeText:
        'A detailed recipe for Tagine. Brown the lamb with spices. Add onions and broth. Simmer slowly in the tagine pot...',
    isFavorite: true,
  ),
  Recipe(
    id: '5',
    name: 'Bastilla',
    category: 'Traditional',
    duration: 40,
    isReady: true,
    imagePath: 'assets/images/recipes/bastilla.png',
    servings: '8 servings',
    calories: '800 Kcal',
    ingredients: [
      'Phyllo pastry',
      'Chicken',
      'Almonds',
      'Eggs',
      'Sugar',
      'Cinnamon',
    ],
    tags: ['Traditional', 'Pie', 'Festive'],
    recipeText:
        'A detailed recipe for Bastilla. Cook the chicken. Prepare the almond filling. Layer with phyllo pastry and bake until golden.',
    isFavorite: true,
  ),
];
