class Recipe {
  final String name;
  final String category;
  final int duration;
  final bool isReady;
  final String imagePath;

  Recipe({
    required this.name,
    required this.category,
    required this.duration,
    required this.isReady,
    required this.imagePath,
  });
}

final List<Recipe> recipes = [
  Recipe(
    name: 'Couscous',
    category: 'Traditional',
    duration: 120,
    isReady: true,
    imagePath: 'assets/images/recipes/couscous.png',
  ),
  Recipe(
    name: 'Hrira',
    category: 'Traditional',
    duration: 60,
    isReady: true,
    imagePath: 'assets/images/recipes/hrira.png',
  ),
  Recipe(
    name: 'Rogag',
    category: 'Traditional',
    duration: 120,
    isReady: true,
    imagePath: 'assets/images/recipes/roqaq.png',
  ),
  Recipe(
    name: 'Tagine',
    category: 'Traditional',
    duration: 60,
    isReady: false,
    imagePath: 'assets/images/recipes/tagine.png',
  ),
  Recipe(
    name: 'Bastilla',
    category: 'Traditional',
    duration: 40,
    isReady: true,
    imagePath: 'assets/images/recipes/bastilla.png',
  ),
];
