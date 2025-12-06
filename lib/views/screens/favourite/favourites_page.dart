import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/widgets/favourites/categories_carousel.dart';
import 'package:chefkit/views/widgets/favourites/favourites_header.dart';
import 'package:chefkit/views/widgets/favourites/recipes_grid.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/blocs/favourites/favourites_state.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    // We defer the event adding to build or use a post-frame callback if we need context
    // But initState has context. However, AppLocalizations might not be ready if it depends on inherited widget
    // usually it is fine.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavouritesBloc>().add(
          LoadFavourites(
            allSavedText: AppLocalizations.of(context)!.allSaved,
            recipeText: AppLocalizations.of(context)!.recipeSingular,
            recipesText: AppLocalizations.of(context)!.recipePlural,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.favorite, size: 52, color: Color(0xFFFF6B6B)),
        ),
        title: const FavouritesHeader(),
        centerTitle: false,
      ),
      body: BlocBuilder<FavouritesBloc, FavouritesState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state.displayRecipes.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavouritesBloc>().add(
                  RefreshFavourites(
                    allSavedText: AppLocalizations.of(context)!.allSaved,
                    recipeText: AppLocalizations.of(context)!.recipeSingular,
                    recipesText: AppLocalizations.of(context)!.recipePlural,
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: const Color(0xFFFF6B6B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      kBottomNavigationBarHeight,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.noFavouritesYet,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.noFavouritesMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (_pageController == null && state.categories.isNotEmpty) {
            // using a large multiplier to simulate infinite scrolling
            // This allows the user to scroll left/right "infinitely"
            // The actual index is calculated using modulo operator
            final initialPage =
                1000 * state.categories.length + state.selectedCategoryIndex;
            _pageController = PageController(
              viewportFraction: 0.55,
              initialPage: initialPage,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavouritesBloc>().add(
                RefreshFavourites(
                  allSavedText: AppLocalizations.of(context)!.allSaved,
                  recipeText: AppLocalizations.of(context)!.recipeSingular,
                  recipesText: AppLocalizations.of(context)!.recipePlural,
                ),
              );
              // Wait a bit to let the user see the visual feedback (state update is fast)
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: const Color(0xFFFF6B6B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    SearchBarWidget(
                      hintText: AppLocalizations.of(context)!.searchYourRecipes,
                      onChanged: (query) {
                        context.read<FavouritesBloc>().add(
                          SearchFavourites(query),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    Text(
                      AppLocalizations.of(context)!.categoriesTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_pageController != null)
                      CategoriesCarousel(
                        categories: state.categories,
                        selectedIndex: state.selectedCategoryIndex,
                        pageController: _pageController!,
                        onCategoryTap: (index) {
                          context.read<FavouritesBloc>().add(
                            SelectCategory(index),
                          );
                        },
                      ),
                    const SizedBox(height: 30),
                    Divider(
                      color: Colors.grey,
                      thickness: 0.6,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 16),
                    RecipesGrid(
                      recipes: state.displayRecipes,
                      onFavoriteToggle: (recipe) {
                        context.read<FavouritesBloc>().add(
                          ToggleFavoriteRecipe(recipe.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
