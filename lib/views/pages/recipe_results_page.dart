import 'package:chefkit/common/app_colors.dart';
import 'package:chefkit/data/recipe_data.dart';
import 'package:chefkit/views/pages/item_page.dart';
import 'package:flutter/material.dart';

class RecipeResultsPage extends StatefulWidget {
  final List<String> selectedIngredients;

  const RecipeResultsPage({super.key, required this.selectedIngredients});

  @override
  State<RecipeResultsPage> createState() => _RecipeResultsPageState();
}

class _RecipeResultsPageState extends State<RecipeResultsPage> {
  late List<Recipe> matchedRecipes;

  @override
  void initState() {
    super.initState();
    _findMatchingRecipes();
  }

  void _findMatchingRecipes() {
    // Simple matching: find recipes that contain at least one of the selected ingredients
    matchedRecipes = dummyRecipes.where((recipe) {
      // Check if any recipe ingredient matches any selected ingredient (case-insensitive partial match)
      return recipe.ingredients.any(
        (recipeIngredient) => widget.selectedIngredients.any(
          (selectedIngredient) =>
              recipeIngredient.toLowerCase().contains(
                selectedIngredient.toLowerCase(),
              ) ||
              selectedIngredient.toLowerCase().contains(
                recipeIngredient.toLowerCase(),
              ),
        ),
      );
    }).toList();

    // If no matches, show all recipes as suggestions
    if (matchedRecipes.isEmpty) {
      matchedRecipes = dummyRecipes;
    }
  }

  int _calculateMatchPercentage(Recipe recipe) {
    int matchCount = 0;
    for (var recipeIngredient in recipe.ingredients) {
      if (widget.selectedIngredients.any(
        (selectedIngredient) =>
            recipeIngredient.toLowerCase().contains(
              selectedIngredient.toLowerCase(),
            ) ||
            selectedIngredient.toLowerCase().contains(
              recipeIngredient.toLowerCase(),
            ),
      )) {
        matchCount++;
      }
    }
    return ((matchCount / recipe.ingredients.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recipe Results",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${matchedRecipes.length} recipe${matchedRecipes.length != 1 ? 's' : ''} found",
              style: TextStyle(
                color: Color(0xFF4A5565),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "LeagueSpartan",
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected ingredients recap
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red600.withOpacity(0.1),
                      AppColors.orange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.red600.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.red600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Your Ingredients:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.selectedIngredients.map((ingredient) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.red600.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.red600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Results header
              Text(
                "Recipes You Can Make",
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Sorted by ingredient match",
                style: TextStyle(
                  color: Color(0xFF6A7282),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 20),

              // Recipe list
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: matchedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = matchedRecipes[index];
                  final matchPercentage = _calculateMatchPercentage(recipe);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemPage(
                            title: recipe.name,
                            imagePath: recipe.imagePath,
                            servings: recipe.servings,
                            calories: recipe.calories,
                            time: '${recipe.duration} min',
                            ingredients: recipe.ingredients,
                            tags: recipe.tags,
                            recipeText: recipe.recipeText,
                            initialFavorite: recipe.isFavorite,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Image and basic info
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Image.asset(
                                  recipe.imagePath,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                                // Match percentage badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getMatchColor(matchPercentage),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "$matchPercentage% Match",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recipe details
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Recipe info row
                                Row(
                                  children: [
                                    _buildInfoChip(
                                      Icons.access_time,
                                      "${recipe.duration} min",
                                    ),
                                    SizedBox(width: 12),
                                    _buildInfoChip(
                                      Icons.restaurant,
                                      recipe.servings,
                                    ),
                                    SizedBox(width: 12),
                                    _buildInfoChip(
                                      Icons.local_fire_department_outlined,
                                      recipe.calories,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Tags
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: recipe.tags.map((tag) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.red600.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.red600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                SizedBox(height: 12),

                                // Matched ingredients
                                Text(
                                  "Matching ingredients:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: recipe.ingredients
                                      .where(
                                        (
                                          ingredient,
                                        ) => widget.selectedIngredients.any(
                                          (selected) =>
                                              ingredient.toLowerCase().contains(
                                                selected.toLowerCase(),
                                              ) ||
                                              selected.toLowerCase().contains(
                                                ingredient.toLowerCase(),
                                              ),
                                        ),
                                      )
                                      .map((ingredient) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success1
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: AppColors.green
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check,
                                                size: 12,
                                                color: AppColors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                ingredient,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) {
      return AppColors.green;
    } else if (percentage >= 50) {
      return AppColors.orange;
    } else {
      return AppColors.red600;
    }
  }
}
