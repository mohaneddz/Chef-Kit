import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../widgets/recipe/recipe_card_widget.dart';
import '../recipe/item_page.dart';
import '../recipe/recipe_details_page.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/models/recipe.dart';

class AllHotRecipesPage extends StatefulWidget {
  const AllHotRecipesPage({Key? key}) : super(key: key);

  @override
  State<AllHotRecipesPage> createState() => _AllHotRecipesPageState();
}

class _AllHotRecipesPageState extends State<AllHotRecipesPage> {
  String _selectedFilter = 'All';
  late Future<List<Recipe>> _recipesFuture;
  final RecipeRepository _recipeRepository = RecipeRepository();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeRepository.fetchHotRecipes();
  }

  String _getLocalizedTitle(Recipe recipe) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' &&
            recipe.titleAr != null &&
            recipe.titleAr!.isNotEmpty
        ? recipe.titleAr!
        : (locale == 'fr' &&
                  recipe.titleFr != null &&
                  recipe.titleFr!.isNotEmpty
              ? recipe.titleFr!
              : recipe.name);
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (_selectedFilter == 'All') return recipes;
    if (_selectedFilter == 'Trending') {
      return recipes.where((r) => r.isTrending).toList();
    }
    // Simple tag-based filtering for other categories
    return recipes.where((r) => r.tags.contains(_selectedFilter)).toList();
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    try {
      await _recipeRepository.toggleFavorite(recipe.id);
      setState(() {
        _recipesFuture = _recipeRepository.fetchHotRecipes();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error toggling favorite: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allRecipes = snapshot.data ?? [];
          final filteredRecipes = _filterRecipes(allRecipes);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        _buildStatBadge(
                          Icons.whatshot,
                          '${allRecipes.length}',
                          AppLocalizations.of(context)!.recipesStat,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(width: 12),
                        _buildStatBadge(
                          Icons.trending_up,
                          '${allRecipes.where((r) => r.isTrending).length}',
                          AppLocalizations.of(context)!.trendingStat,
                          AppColors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBadge(
                          Icons.favorite,
                          '${allRecipes.where((r) => r.isFavorite).length}',
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      final title = _getLocalizedTitle(recipe);
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
                              title: title,
                              subtitle: title,
                              imageUrl: recipe.imageUrl,
                              isFavorite: recipe.isFavorite,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailsPage(recipe: recipe),
                                  ),
                                );
                              },
                              onFavoritePressed: () => _toggleFavorite(recipe),
                            ),
                            if (recipe.isTrending)
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
          );
        },
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
