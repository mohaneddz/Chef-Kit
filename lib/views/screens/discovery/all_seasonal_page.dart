import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../widgets/recipe/seasonal_item_widget.dart';
import '../recipe/item_page.dart';
import '../recipe/recipe_details_page.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/models/recipe.dart';

class AllSeasonalPage extends StatefulWidget {
  const AllSeasonalPage({Key? key}) : super(key: key);

  @override
  State<AllSeasonalPage> createState() => _AllSeasonalPageState();
}

class _AllSeasonalPageState extends State<AllSeasonalPage> {
  String _selectedSeason = 'All';
  late Future<List<Recipe>> _recipesFuture;
  final RecipeRepository _recipeRepository = RecipeRepository();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeRepository.fetchSeasonalRecipes();
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

  String _getSeasonFromTags(List<String> tags) {
    if (tags.contains('Spring')) return 'Spring';
    if (tags.contains('Summer')) return 'Summer';
    if (tags.contains('Autumn')) return 'Autumn';
    if (tags.contains('Winter')) return 'Winter';
    return 'All';
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
          final filteredRecipes = _selectedSeason == 'All'
              ? allRecipes
              : allRecipes
                    .where((r) => r.tags.contains(_selectedSeason))
                    .toList();

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
                              const Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 28,
                              ),
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
                                allRecipes,
                                'Spring',
                                AppLocalizations.of(context)!.seasonSpring,
                                Icons.local_florist,
                              ),
                              const SizedBox(width: 12),
                              _buildSeasonStat(
                                allRecipes,
                                'Summer',
                                AppLocalizations.of(context)!.seasonSummer,
                                Icons.wb_sunny,
                              ),
                              const SizedBox(width: 12),
                              _buildSeasonStat(
                                allRecipes,
                                'Autumn',
                                AppLocalizations.of(context)!.seasonAutumn,
                                Icons.eco,
                              ),
                              const SizedBox(width: 12),
                              _buildSeasonStat(
                                allRecipes,
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
                      final season = _getSeasonFromTags(recipe.tags);
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
                              title: recipe.name,
                              subtitle: recipe.description,
                              imageUrl: recipe.imageUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailsPage(
                                      recipeId: recipe.id,
                                      recipeName: recipe.name,
                                      recipeDescription: recipe.description,
                                      recipeImageUrl: recipe.imageUrl,
                                      recipePrepTime: recipe.prepTime,
                                      recipeCookTime: recipe.cookTime,
                                      recipeCalories: recipe.calories,
                                      recipeServingsCount: recipe.servingsCount,
                                      recipeIngredients: recipe.ingredients,
                                      recipeInstructions: recipe.instructions,
                                      recipeTags: recipe.tags,
                                      initialFavorite: recipe.isFavorite,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (season != 'All')
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSeasonColor(season),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getSeasonColor(
                                          season,
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
                                        _getSeasonIcon(season),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        season,
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
          );
        },
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

  Widget _buildSeasonStat(
    List<Recipe> allRecipes,
    String seasonKey,
    String label,
    IconData icon,
  ) {
    final count = allRecipes.where((r) => r.tags.contains(seasonKey)).length;
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
