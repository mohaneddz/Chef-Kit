import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../widgets/discovery/recipe_card_widget.dart';

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
    },
    {
      'title': 'Couscous/ Berbousha',
      'subtitle': 'steamed and dried semolina flour',
      'imageUrl': 'assets/images/couscous.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': true,
    },
    {
      'title': 'Barkoukes',
      'subtitle': 'Traditional Soup',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'isFavorite': false,
      'category': 'Soup',
      'trending': false,
    },
    {
      'title': 'Escalope',
      'subtitle': 'Delicious & Crispy',
      'imageUrl': 'assets/images/escalope.png',
      'isFavorite': false,
      'category': 'Quick',
      'trending': true,
    },
    {
      'title': 'Tajine',
      'subtitle': 'Slow cooked perfection',
      'imageUrl': 'assets/images/tomato.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
    },
    {
      'title': 'Chorba',
      'subtitle': 'Hearty soup',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'isFavorite': false,
      'category': 'Soup',
      'trending': true,
    },
    {
      'title': 'Rechta',
      'subtitle': 'Traditional noodles',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
    },
    {
      'title': 'Chakhchoukha',
      'subtitle': 'Savory delight',
      'imageUrl': 'assets/images/couscous.png',
      'isFavorite': false,
      'category': 'Traditional',
      'trending': false,
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
      _allRecipes[originalIndex]['isFavorite'] = !_allRecipes[originalIndex]['isFavorite'];
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
        title: const Text(
          'Hot Recipes',
          style: TextStyle(
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
                      'recipes',
                      const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      Icons.trending_up,
                      '${_allRecipes.where((r) => r['trending'] == true).length}',
                      'trending',
                      AppColors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      Icons.favorite,
                      '${_allRecipes.where((r) => r['isFavorite'] == true).length}',
                      'favorites',
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
                      _buildFilterChip('All', Icons.grid_view),
                      const SizedBox(width: 8),
                      _buildFilterChip('Trending', Icons.local_fire_department),
                      const SizedBox(width: 8),
                      _buildFilterChip('Traditional', Icons.restaurant),
                      const SizedBox(width: 8),
                      _buildFilterChip('Soup', Icons.soup_kitchen),
                      const SizedBox(width: 8),
                      _buildFilterChip('Quick', Icons.bolt),
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
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening ${recipe['title']}...'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.red600,
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
                                  colors: [Color(0xFFFF6B6B), Color(0xFFFFAA6B)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'HOT',
                                    style: TextStyle(
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

  Widget _buildStatBadge(IconData icon, String value, String label, Color color) {
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

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
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
              label,
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
