import 'package:chefkit/blocs/recipe_results/recipe_results_bloc.dart';
import 'package:chefkit/blocs/recipe_results/recipe_results_events.dart';
import 'package:chefkit/blocs/recipe_results/recipe_results_state.dart';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/domain/models/recipe.dart';
import 'package:chefkit/domain/repositories/recipe_repository.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/recipe/recipe_details_page.dart';
import 'package:chefkit/views/widgets/recipe/recipe_card_widget.dart';
import 'package:chefkit/views/widgets/login_required_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeResultsPage extends StatelessWidget {
  final List<String> selectedIngredients;
  final List<Recipe>? initialRecipes;

  const RecipeResultsPage({
    super.key,
    required this.selectedIngredients,
    this.initialRecipes,
  });

  String _getLocalizedTitle(BuildContext context, Recipe recipe) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BlocProvider(
      create: (context) {
        final bloc = RecipeResultsBloc(
          recipeRepository: context.read<RecipeRepository>(),
        );
        if (initialRecipes != null) {
          bloc.add(SetRecipeResults(initialRecipes!));
        } else {
          bloc.add(LoadRecipeResults(selectedIngredients));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<RecipeResultsBloc, RecipeResultsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recipeResultsTitle,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.recipesFound(state.matchedRecipes.length),
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
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
                                  color: isDark
                                      ? Color(0xFF2A2A2A)
                                      : Colors.white,
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
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.sortedByMatch,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        // Always use 2 columns for compact 2x2 grid
                        const crossAxisCount = 2;
                        const spacing = 12.0;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.start,
                          children: state.matchedRecipes.map((recipe) {
                            final double itemWidth =
                                (availableWidth - spacing) / crossAxisCount;
                            final title = _getLocalizedTitle(context, recipe);
                            return SizedBox(
                              width: itemWidth,
                              height: itemWidth * 1.1, // Compact aspect ratio
                              child: RecipeCardWidget(
                                title: title,
                                subtitle: title,
                                imageUrl: recipe.imageUrl,
                                isFavorite: recipe.isFavorite,
                                onFavoritePressed: () {
                                  final userId = context
                                      .read<AuthCubit>()
                                      .state
                                      .userId;
                                  if (userId == null) {
                                    showLoginRequiredModal(
                                      context,
                                      customMessage: AppLocalizations.of(
                                        context,
                                      )!.loginRequiredFavorites,
                                    );
                                    return;
                                  }
                                  context.read<RecipeResultsBloc>().add(
                                    ToggleRecipeResultFavorite(recipe.id),
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailsPage(recipe: recipe),
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
