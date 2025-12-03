import 'package:chefkit/blocs/home/recipe_card_widget.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/views/screens/item_page.dart';
import 'package:flutter/material.dart';

class RecipesGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onFavoriteToggle;

  const RecipesGrid({
    super.key,
    required this.recipes,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        int crossAxisCount;

        if (availableWidth < 250) {
          crossAxisCount = 1;
        } else if (availableWidth < 540) {
          crossAxisCount = 2;
        } else if (availableWidth < 740) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: recipes.map((r) {
              final double itemWidth =
                  (availableWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
              return SizedBox(
                width: itemWidth,
                height: itemWidth / 0.75,
                child: RecipeCardWidget(
                  title: r.title,
                  subtitle: r.subtitle,
                  imageUrl: r.imageUrl,
                  isFavorite: r.isFavorite,
                  onFavoritePressed: () => onFavoriteToggle(r),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemPage(
                          title: r.title,
                          imagePath: r.imageUrl,
                          servings: r.servings,
                          calories: r.calories,
                          time: r.time,
                          ingredients: r.ingredients,
                          tags: r.tags,
                          recipeText: r.recipeText,
                          initialFavorite: r.isFavorite,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
