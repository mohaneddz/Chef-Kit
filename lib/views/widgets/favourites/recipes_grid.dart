import 'package:chefkit/views/widgets/recipe/recipe_card_widget.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/views/screens/recipe/recipe_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/l10n/app_localizations.dart';

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
                  title: r.name,
                  subtitle: r.description,
                  imageUrl: r.imageUrl,
                  isFavorite: r.isFavorite,
                  onFavoritePressed: () => onFavoriteToggle(r),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeId: r.id,
                          recipeName: r.name,
                          recipeDescription: r.description,
                          recipeImageUrl: r.imageUrl,
                          recipePrepTime: r.prepTime,
                          recipeCookTime: r.cookTime,
                          recipeCalories: r.calories,
                          recipeServingsCount: r.servingsCount,
                          recipeIngredients: r.ingredients,
                          recipeInstructions: r.instructions,
                          recipeTags: r.tags,
                          initialFavorite: r.isFavorite,
                        ),
                      ),
                    );
                    // Refresh favourites when returning from details page
                    // This creates a "live" feel if the user unliked the recipe inside details
                    if (context.mounted) {
                      context.read<FavouritesBloc>().add(
                        RefreshFavourites(
                          allSavedText: AppLocalizations.of(context)!.allSaved,
                          recipeText: AppLocalizations.of(
                            context,
                          )!.recipeSingular,
                          recipesText: AppLocalizations.of(
                            context,
                          )!.recipePlural,
                        ),
                      );
                    }
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
