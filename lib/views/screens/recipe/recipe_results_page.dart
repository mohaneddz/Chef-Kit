import 'package:chefkit/blocs/recipe_results/recipe_results_bloc.dart';
import 'package:chefkit/blocs/recipe_results/recipe_results_events.dart';
import 'package:chefkit/blocs/recipe_results/recipe_results_state.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/domain/repositories/recipe/recipe_repo.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/recipe/item_page.dart';
import 'package:chefkit/views/widgets/recipe/recipe_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeResultsPage extends StatelessWidget {
  final List<String> selectedIngredients;

  const RecipeResultsPage({super.key, required this.selectedIngredients});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecipeResultsBloc(recipeRepository: context.read<RecipeRepository>())
            ..add(LoadRecipeResults(selectedIngredients)),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<RecipeResultsBloc, RecipeResultsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recipeResultsTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.recipesFound(state.matchedRecipes.length),
                    style: const TextStyle(
                      color: Color(0xFF4A5565),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "LeagueSpartan",
                    ),
                  ),
                ],
              );
            },
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<RecipeResultsBloc, RecipeResultsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.error(state.error.toString()),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.red600.withOpacity(0.1),
                            AppColors.orange.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.red600.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.red600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.yourIngredients,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.red600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedIngredients.map((ingredient) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
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
                                  style: const TextStyle(
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
                    const SizedBox(height: 30),
                    Text(
                      AppLocalizations.of(context)!.recipesYouCanMake,
                      style: const TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.sortedByMatch,
                      style: const TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        int crossAxisCount;

                        if (availableWidth < 400) {
                          crossAxisCount = 1;
                        } else if (availableWidth < 700) {
                          crossAxisCount = 2;
                        } else {
                          crossAxisCount = 3;
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          alignment: WrapAlignment.start,
                          children: state.matchedRecipes.map((recipe) {
                            final double itemWidth = crossAxisCount == 1
                                ? availableWidth
                                : (availableWidth - (crossAxisCount - 1) * 16) /
                                      crossAxisCount;
                            return SizedBox(
                              width: itemWidth,
                              height: itemWidth / 0.75,
                              child: RecipeCardWidget(
                                title: recipe.name,
                                subtitle: recipe.description,
                                imageUrl: recipe.imageUrl,
                                isFavorite: recipe.isFavorite,
                                onFavoritePressed: () {
                                  context.read<RecipeResultsBloc>().add(
                                    ToggleRecipeResultFavorite(recipe.id),
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemPage(
                                        title: recipe.name,
                                        imagePath: recipe.imageUrl,
                                        servings: AppLocalizations.of(context)!
                                            .servings(
                                              recipe.servingsCount.toString(),
                                            ),
                                        calories: AppLocalizations.of(
                                          context,
                                        )!.calories(recipe.calories.toString()),
                                        time: AppLocalizations.of(context)!
                                            .minutes(
                                              (recipe.prepTime +
                                                      recipe.cookTime)
                                                  .toString(),
                                            ),
                                        ingredients: recipe.ingredients,
                                        tags: recipe.tags,
                                        recipeText: recipe.instructions.join(
                                          '\n',
                                        ),
                                        initialFavorite: recipe.isFavorite,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
