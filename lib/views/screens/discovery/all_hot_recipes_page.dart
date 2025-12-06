import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../widgets/recipe/recipe_card_widget.dart';
import '../recipe/item_page.dart';

class AllHotRecipesPage extends StatefulWidget {
  const AllHotRecipesPage({Key? key}) : super(key: key);

  @override
  State<AllHotRecipesPage> createState() => _AllHotRecipesPageState();
}

class _AllHotRecipesPageState extends State<AllHotRecipesPage> {
  String _selectedFilter = 'All';

  // Sample recipe data - you can replace this with real data later
  final List<Map<String, dynamic>> _allRecipes = [
    {
      'title': 'Mahjouba',
      'subtitle': 'Authentic Algerian\nClassic',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': true,
      'servings': '4 servings',
      'calories': '450 Kcal',
      'time': '45 min',
      'ingredients': ['Semolina', 'Tomatoes', 'Onions', 'Peppers', 'Spices'],
      'tags': ['Traditional', 'Algerian', 'Savory'],
      'recipeText':
          'Mahjouba is a traditional Algerian flatbread stuffed with a savory tomato and pepper mixture. Start by preparing the thin semolina dough, then cook the filling with tomatoes, onions, and spices. Fold the dough over the filling and cook on a griddle until golden brown.',
    },
    {
      'title': 'Couscous/ Berbousha',
      'subtitle': 'steamed and dried semolina flour',
      'imageUrl': 'assets/images/couscous.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': true,
      'servings': '6 servings',
      'calories': '650 Kcal',
      'time': '120 min',
      'ingredients': [
        'Couscous',
        'Chicken',
        'Zucchini',
        'Carrots',
        'Chickpeas',
        'Turnips',
      ],
      'tags': ['Traditional', 'Algerian', 'Main Dish'],
      'recipeText':
          'A traditional North African dish made with steamed semolina granules. First, prepare the vegetables by cutting them into large pieces. Cook the meat with onions and spices. Steam the couscous grains multiple times for a fluffy texture. Serve with the meat and vegetables on top.',
    },
    {
      'title': 'Barkoukes',
      'subtitle': 'Traditional Soup',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'isFavorite': false,
      'category': 'Soup',
      'trending': false,
      'servings': '5 servings',
      'calories': '380 Kcal',
      'time': '90 min',
      'ingredients': [
        'Barkoukes pasta',
        'Lamb',
        'Chickpeas',
        'Tomatoes',
        'Spices',
        'Herbs',
      ],
      'tags': ['Traditional', 'Soup', 'Hearty'],
      'recipeText':
          'Barkoukes is a traditional North African soup made with handmade pasta pearls. Cook the meat with chickpeas and spices. Add the barkoukes pasta and simmer until tender. Season with fresh herbs and serve hot.',
    },
    {
      'title': 'Escalope',
      'subtitle': 'Delicious & Crispy',
      'imageUrl': 'assets/images/ingredients/escalope.png',
      'isFavorite': false,
      'category': 'Quick',
      'trending': true,
      'servings': '4 servings',
      'calories': '520 Kcal',
      'time': '30 min',
      'ingredients': [
        'Chicken breast',
        'Eggs',
        'Breadcrumbs',
        'Flour',
        'Oil',
        'Spices',
      ],
      'tags': ['Quick', 'Fried', 'Crispy'],
      'recipeText':
          'Crispy breaded chicken cutlets that are golden and delicious. Pound the chicken breast thin, coat in flour, dip in beaten eggs, then cover with breadcrumbs. Fry in hot oil until golden brown on both sides. Serve with fries or salad.',
    },
    {
      'title': 'Tajine',
      'subtitle': 'Slow cooked perfection',
      'imageUrl': 'assets/images/ingredients/tomato.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
      'servings': '4 servings',
      'calories': '580 Kcal',
      'time': '150 min',
      'ingredients': [
        'Lamb',
        'Prunes',
        'Almonds',
        'Onions',
        'Saffron',
        'Ginger',
      ],
      'tags': ['Traditional', 'Sweet & Savory', 'Slow-cooked'],
      'recipeText':
          'A traditional Moroccan slow-cooked stew. Brown the lamb with spices including saffron and ginger. Add onions, prunes, and almonds. Let it simmer slowly in a traditional tagine pot for hours until the meat is tender and falls off the bone.',
    },
    {
      'title': 'Chorba',
      'subtitle': 'Hearty soup',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'isFavorite': false,
      'category': 'Soup',
      'trending': true,
      'servings': '6 servings',
      'calories': '320 Kcal',
      'time': '60 min',
      'ingredients': [
        'Lamb',
        'Vermicelli',
        'Chickpeas',
        'Tomatoes',
        'Spices',
        'Lemon',
      ],
      'tags': ['Traditional', 'Soup', 'Ramadan'],
      'recipeText':
          'A hearty Algerian soup perfect for breaking fast during Ramadan. Cook lamb with tomatoes and spices. Add chickpeas and vermicelli pasta. Season with lemon juice and fresh cilantro before serving.',
    },
    {
      'title': 'Rechta',
      'subtitle': 'Traditional noodles',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
      'servings': '5 servings',
      'calories': '620 Kcal',
      'time': '90 min',
      'ingredients': [
        'Flour',
        'Chicken',
        'Chickpeas',
        'Onions',
        'Turnips',
        'Spices',
      ],
      'tags': ['Traditional', 'Pasta', 'Festive'],
      'recipeText':
          'Rechta features homemade flat noodles served with chicken and vegetables in a flavorful sauce. Make the pasta dough, roll it thin, and cut into strips. Cook chicken with chickpeas and vegetables. Serve the noodles topped with the chicken mixture.',
    },
    {
      'title': 'Chakhchoukha',
      'subtitle': 'Savory delight',
      'imageUrl': 'assets/images/couscous.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
      'servings': '6 servings',
      'calories': '680 Kcal',
      'time': '120 min',
      'ingredients': [
        'Rougag bread',
        'Lamb',
        'Chickpeas',
        'Tomatoes',
        'Spices',
        'Vegetables',
      ],
      'tags': ['Traditional', 'Algerian', 'Festive'],
      'recipeText':
          'A traditional Algerian dish from the Biskra region. Prepare torn pieces of rougag bread. Cook lamb with vegetables and chickpeas in a rich tomato sauce. Pour the sauce over the bread pieces and let it soak before serving.',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_selectedFilter == 'All') return _allRecipes;
    if (_selectedFilter == 'Trending') {
      return _allRecipes.where((r) => r['trending'] == true).toList();
    }
    return _allRecipes.where((r) => r['category'] == _selectedFilter).toList();
  }

  void _toggleFavorite(int index) {
    setState(() {
      final recipe = _filteredRecipes[index];
      final originalIndex = _allRecipes.indexOf(recipe);
      _allRecipes[originalIndex]['isFavorite'] =
          !_allRecipes[originalIndex]['isFavorite'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _filteredRecipes;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.hotRecipes,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    _buildStatBadge(
                      Icons.whatshot,
                      '${_allRecipes.length}',
                      AppLocalizations.of(context)!.recipesStat,
                      const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      Icons.trending_up,
                      '${_allRecipes.where((r) => r['trending'] == true).length}',
                      AppLocalizations.of(context)!.trendingStat,
                      AppColors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      Icons.favorite,
                      '${_allRecipes.where((r) => r['isFavorite'] == true).length}',
                      AppLocalizations.of(context)!.favoritesStat,
                      AppColors.red600,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All',
                        AppLocalizations.of(context)!.filterAll,
                        Icons.grid_view,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Trending',
                        AppLocalizations.of(context)!.filterTrending,
                        Icons.local_fire_department,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Traditional',
                        AppLocalizations.of(context)!.filterTraditional,
                        Icons.restaurant,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Soup',
                        AppLocalizations.of(context)!.filterSoup,
                        Icons.soup_kitchen,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Quick',
                        AppLocalizations.of(context)!.filterQuick,
                        Icons.bolt,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recipes Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Stack(
                      children: [
                        RecipeCardWidget(
                          title: recipe['title'],
                          subtitle: recipe['subtitle'],
                          imageUrl: recipe['imageUrl'],
                          isFavorite: recipe['isFavorite'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemPage(
                                  title: recipe['title'],
                                  imagePath: recipe['imageUrl'],
                                  servings: recipe['servings'],
                                  calories: recipe['calories'],
                                  time: recipe['time'],
                                  ingredients: List<String>.from(
                                    recipe['ingredients'],
                                  ),
                                  tags: List<String>.from(recipe['tags']),
                                  recipeText: recipe['recipeText'],
                                  initialFavorite: recipe['isFavorite'],
                                ),
                              ),
                            );
                          },
                          onFavoritePressed: () => _toggleFavorite(index),
                        ),
                        if (recipe['trending'] == true)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFFAA6B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    AppLocalizations.of(context)!.hotBadge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String filterKey,
    String displayLabel,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                )
              : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              displayLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
