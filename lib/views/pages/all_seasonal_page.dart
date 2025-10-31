import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../widgets/discovery/seasonal_item_widget.dart';

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
    },
    {
      'title': 'Strawberry Salad',
      'subtitle': 'with Balsamic Glaze',
      'imageUrl': 'assets/images/tomato.png',
      'season': 'Summer',
    },
    {
      'title': 'Winter Couscous',
      'subtitle': 'Warm & Comforting',
      'imageUrl': 'assets/images/couscous.png',
      'season': 'Winter',
    },
    {
      'title': 'Autumn Tajine',
      'subtitle': 'Seasonal vegetables',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'season': 'Autumn',
    },
    {
      'title': 'Spring Chorba',
      'subtitle': 'Fresh herbs',
      'imageUrl': 'assets/images/Barkoukes.jpg',
      'season': 'Spring',
    },
    {
      'title': 'Summer Escalope',
      'subtitle': 'Light & Crispy',
      'imageUrl': 'assets/images/escalope.png',
      'season': 'Summer',
    },
    {
      'title': 'Harvest Soup',
      'subtitle': 'Farm-fresh ingredients',
      'imageUrl': 'assets/images/tomato.png',
      'season': 'Autumn',
    },
    {
      'title': 'Spring Salad',
      'subtitle': 'Mixed greens',
      'imageUrl': 'assets/images/Mahjouba.jpeg',
      'season': 'Spring',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_selectedSeason == 'All') return allSeasonalRecipes;
    return allSeasonalRecipes.where((r) => r['season'] == _selectedSeason).toList();
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
        title: const Text(
          'Seasonal Delights',
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
                // Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00BC7D),
                        Color(0xFF00C950),
                      ],
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
                        children: const [
                          Icon(Icons.eco, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Fresh This Season',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Discover recipes perfect for the current season',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSeasonStat('Spring', Icons.local_florist),
                          const SizedBox(width: 12),
                          _buildSeasonStat('Summer', Icons.wb_sunny),
                          const SizedBox(width: 12),
                          _buildSeasonStat('Autumn', Icons.eco),
                          const SizedBox(width: 12),
                          _buildSeasonStat('Winter', Icons.ac_unit),
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
                      _buildSeasonChip('All', Icons.calendar_today, AppColors.red600),
                      const SizedBox(width: 8),
                      _buildSeasonChip('Spring', Icons.local_florist, const Color(0xFF00BC7D)),
                      const SizedBox(width: 8),
                      _buildSeasonChip('Summer', Icons.wb_sunny, const Color(0xFFFFAA6B)),
                      const SizedBox(width: 8),
                      _buildSeasonChip('Autumn', Icons.eco, const Color(0xFFFF914D)),
                      const SizedBox(width: 8),
                      _buildSeasonChip('Winter', Icons.ac_unit, const Color(0xFF6B9EFF)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${filteredRecipes.length} ${_selectedSeason == 'All' ? 'seasonal' : _selectedSeason.toLowerCase()} recipes',
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
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SeasonalItemWidget(
                          title: recipe['title'],
                          subtitle: recipe['subtitle'],
                          imageUrl: recipe['imageUrl'],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening ${recipe['title']}...'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: _getSeasonColor(recipe['season']),
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
                                  color: _getSeasonColor(recipe['season']).withOpacity(0.3),
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

  Widget _buildSeasonStat(String season, IconData icon) {
    final count = allSeasonalRecipes.where((r) => r['season'] == season).length;
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

  Widget _buildSeasonChip(String label, IconData icon, Color color) {
    final isSelected = _selectedSeason == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSeason = label;
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
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
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
