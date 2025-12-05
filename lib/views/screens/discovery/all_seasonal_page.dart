import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../widgets/recipe/seasonal_item_widget.dart';
import '../recipe/item_page.dart';

class AllSeasonalPage extends StatefulWidget {
  const AllSeasonalPage({Key? key}) : super(key: key);

  @override
  State<AllSeasonalPage> createState() => _AllSeasonalPageState();
}

class _AllSeasonalPageState extends State<AllSeasonalPage> {
  String _selectedSeason = 'All';

  // Sample seasonal data - you can replace this with real data later
  final List<Map<String, dynamic>> allSeasonalRecipes = [
    {
      'title': 'Barkoukes/ Eich',
      'subtitle': 'Soup',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'season': 'Winter',
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
          'Barkoukes is a traditional North African soup perfect for cold winter days. Cook the meat with chickpeas and spices. Add the barkoukes pasta and simmer until tender. Season with fresh herbs and serve hot.',
    },
    {
      'title': 'Strawberry Salad',
      'subtitle': 'with Balsamic Glaze',
      'imageUrl': 'assets/images/ingredients/tomato.png',
      'season': 'Summer',
      'servings': '2 servings',
      'calories': '180 Kcal',
      'time': '15 min',
      'ingredients': [
        'Strawberries',
        'Mixed greens',
        'Goat cheese',
        'Walnuts',
        'Balsamic glaze',
      ],
      'tags': ['Salad', 'Fresh', 'Light'],
      'recipeText':
          'A refreshing summer salad featuring fresh strawberries. Toss mixed greens with sliced strawberries, crumbled goat cheese, and walnuts. Drizzle with balsamic glaze just before serving.',
    },
    {
      'title': 'Winter Couscous',
      'subtitle': 'Warm & Comforting',
      'imageUrl': 'assets/images/couscous.png',
      'season': 'Winter',
      'servings': '6 servings',
      'calories': '680 Kcal',
      'time': '120 min',
      'ingredients': [
        'Couscous',
        'Lamb',
        'Root vegetables',
        'Chickpeas',
        'Winter spices',
      ],
      'tags': ['Traditional', 'Hearty', 'Warm'],
      'recipeText':
          'A warming winter version of traditional couscous featuring root vegetables. Slow-cook lamb with winter vegetables like turnips and carrots. Steam the couscous and serve with the hearty stew.',
    },
    {
      'title': 'Autumn Tajine',
      'subtitle': 'Seasonal vegetables',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'season': 'Autumn',
      'servings': '4 servings',
      'calories': '540 Kcal',
      'time': '100 min',
      'ingredients': [
        'Lamb',
        'Pumpkin',
        'Chestnuts',
        'Dried figs',
        'Autumn spices',
      ],
      'tags': ['Traditional', 'Seasonal', 'Slow-cooked'],
      'recipeText':
          'An autumn twist on traditional tagine featuring seasonal pumpkin and chestnuts. Cook lamb with autumn spices, pumpkin chunks, and chestnuts. Add dried figs for sweetness and simmer until tender.',
    },
    {
      'title': 'Spring Chorba',
      'subtitle': 'Fresh herbs',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'season': 'Spring',
      'servings': '5 servings',
      'calories': '300 Kcal',
      'time': '55 min',
      'ingredients': [
        'Lamb',
        'Spring vegetables',
        'Fresh herbs',
        'Lentils',
        'Lemon',
      ],
      'tags': ['Soup', 'Light', 'Fresh'],
      'recipeText':
          'A light spring version of chorba featuring fresh seasonal vegetables and herbs. Cook with tender spring vegetables, fresh cilantro, parsley, and a squeeze of lemon for brightness.',
    },
    {
      'title': 'Summer Escalope',
      'subtitle': 'Light & Crispy',
      'imageUrl': 'assets/images/ingredients/escalope.png',
      'season': 'Summer',
      'servings': '4 servings',
      'calories': '480 Kcal',
      'time': '25 min',
      'ingredients': [
        'Chicken breast',
        'Lemon zest',
        'Herbs',
        'Breadcrumbs',
        'Olive oil',
      ],
      'tags': ['Quick', 'Light', 'Crispy'],
      'recipeText':
          'A light summer version of escalope with lemon and fresh herbs. Season chicken with lemon zest and fresh herbs, coat in breadcrumbs, and pan-fry until golden. Perfect with a fresh summer salad.',
    },
    {
      'title': 'Harvest Soup',
      'subtitle': 'Farm-fresh ingredients',
      'imageUrl': 'assets/images/ingredients/tomato.png',
      'season': 'Autumn',
      'servings': '6 servings',
      'calories': '280 Kcal',
      'time': '45 min',
      'ingredients': ['Tomatoes', 'Squash', 'Beans', 'Corn', 'Harvest herbs'],
      'tags': ['Soup', 'Vegetarian', 'Seasonal'],
      'recipeText':
          'Celebrate the autumn harvest with this vegetable-rich soup. Combine roasted tomatoes, squash, beans, and corn with herbs. Simmer until flavors meld together beautifully.',
    },
    {
      'title': 'Spring Salad',
      'subtitle': 'Mixed greens',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'season': 'Spring',
      'servings': '3 servings',
      'calories': '160 Kcal',
      'time': '10 min',
      'ingredients': [
        'Spring greens',
        'Radishes',
        'Peas',
        'Mint',
        'Lemon dressing',
      ],
      'tags': ['Salad', 'Fresh', 'Light'],
      'recipeText':
          'A fresh spring salad bursting with color and flavor. Toss tender spring greens with crisp radishes, sweet peas, and fresh mint. Dress with a light lemon vinaigrette.',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_selectedSeason == 'All') return allSeasonalRecipes;
    return allSeasonalRecipes
        .where((r) => r['season'] == _selectedSeason)
        .toList();
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring':
        return const Color(0xFF00BC7D);
      case 'Summer':
        return const Color(0xFFFFAA6B);
      case 'Autumn':
        return const Color(0xFFFF914D);
      case 'Winter':
        return const Color(0xFF6B9EFF);
      default:
        return AppColors.red600;
    }
  }

  IconData _getSeasonIcon(String season) {
    switch (season) {
      case 'Spring':
        return Icons.local_florist;
      case 'Summer':
        return Icons.wb_sunny;
      case 'Autumn':
        return Icons.eco;
      case 'Winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
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
          AppLocalizations.of(context)!.seasonalDelightsTitle,
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
                // Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BC7D), Color(0xFF00C950)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BC7D).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.freshThisSeason,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.seasonalDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSeasonStat(
                            'Spring',
                            AppLocalizations.of(context)!.seasonSpring,
                            Icons.local_florist,
                          ),
                          const SizedBox(width: 12),
                          _buildSeasonStat(
                            'Summer',
                            AppLocalizations.of(context)!.seasonSummer,
                            Icons.wb_sunny,
                          ),
                          const SizedBox(width: 12),
                          _buildSeasonStat(
                            'Autumn',
                            AppLocalizations.of(context)!.seasonAutumn,
                            Icons.eco,
                          ),
                          const SizedBox(width: 12),
                          _buildSeasonStat(
                            'Winter',
                            AppLocalizations.of(context)!.seasonWinter,
                            Icons.ac_unit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Season Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSeasonChip(
                        'All',
                        AppLocalizations.of(context)!.filterAll,
                        Icons.calendar_today,
                        AppColors.red600,
                      ),
                      const SizedBox(width: 8),
                      _buildSeasonChip(
                        'Spring',
                        AppLocalizations.of(context)!.seasonSpring,
                        Icons.local_florist,
                        const Color(0xFF00BC7D),
                      ),
                      const SizedBox(width: 8),
                      _buildSeasonChip(
                        'Summer',
                        AppLocalizations.of(context)!.seasonSummer,
                        Icons.wb_sunny,
                        const Color(0xFFFFAA6B),
                      ),
                      const SizedBox(width: 8),
                      _buildSeasonChip(
                        'Autumn',
                        AppLocalizations.of(context)!.seasonAutumn,
                        Icons.eco,
                        const Color(0xFFFF914D),
                      ),
                      const SizedBox(width: 8),
                      _buildSeasonChip(
                        'Winter',
                        AppLocalizations.of(context)!.seasonWinter,
                        Icons.ac_unit,
                        const Color(0xFF6B9EFF),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.seasonalRecipesCount(
                    filteredRecipes.length,
                    _selectedSeason == 'All'
                        ? AppLocalizations.of(
                            context,
                          )!.seasonalDelights.toLowerCase()
                        : _getLocalizedSeasonName(
                            context,
                            _selectedSeason,
                          ).toLowerCase(),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Recipes List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView.separated(
                itemCount: filteredRecipes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Stack(
                      children: [
                        SeasonalItemWidget(
                          title: recipe['title'],
                          subtitle: recipe['subtitle'],
                          imageUrl: recipe['imageUrl'],
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
                                  initialFavorite: false,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeasonColor(recipe['season']),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _getSeasonColor(
                                    recipe['season'],
                                  ).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getSeasonIcon(recipe['season']),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe['season'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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

  String _getLocalizedSeasonName(BuildContext context, String seasonKey) {
    switch (seasonKey) {
      case 'Spring':
        return AppLocalizations.of(context)!.seasonSpring;
      case 'Summer':
        return AppLocalizations.of(context)!.seasonSummer;
      case 'Autumn':
        return AppLocalizations.of(context)!.seasonAutumn;
      case 'Winter':
        return AppLocalizations.of(context)!.seasonWinter;
      default:
        return seasonKey;
    }
  }

  Widget _buildSeasonStat(String seasonKey, String label, IconData icon) {
    final count = allSeasonalRecipes
        .where((r) => r['season'] == seasonKey)
        .length;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonChip(
    String filterKey,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedSeason == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSeason = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : color,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
