import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/widgets/favourites/categories_carousel.dart';
import 'package:chefkit/views/widgets/favourites/favourites_header.dart';
import 'package:chefkit/views/widgets/favourites/recipes_grid.dart';
import 'package:chefkit/blocs/favourites/favourites_bloc.dart';
import 'package:chefkit/blocs/favourites/favourites_events.dart';
import 'package:chefkit/blocs/favourites/favourites_state.dart';
import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';
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
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      context.read<FavouritesBloc>().add(
        LoadFavourites(
          allSavedText: AppLocalizations.of(context)!.allSaved,
          recipeText: AppLocalizations.of(context)!.recipeSingular,
          recipesText: AppLocalizations.of(context)!.recipePlural,
          locale: newLocale.languageCode,
          otherText: "Other",
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if user is logged in
    final userId = context.watch<AuthCubit>().state.userId;
    if (userId == null) {
      return _buildGuestFavouritesView(context, theme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.favorite, size: 52, color: Color(0xFFFF6B6B)),
        ),
        title: const FavouritesHeader(),
        centerTitle: false,
      ),
      body: BlocListener<FavouritesBloc, FavouritesState>(
        listenWhen: (prev, curr) =>
            curr.syncError != null && prev.syncError != curr.syncError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.syncError!),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: BlocBuilder<FavouritesBloc, FavouritesState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
              );
            }

            // Check if user has no favorites at all (categories is empty)
            if (state.categories.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FavouritesBloc>().add(
                    RefreshFavourites(
                      allSavedText: AppLocalizations.of(context)!.allSaved,
                      recipeText: AppLocalizations.of(context)!.recipeSingular,
                      recipesText: AppLocalizations.of(context)!.recipePlural,
                      locale: Localizations.localeOf(context).languageCode,
                      otherText: "Other",
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
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.noFavouritesYet,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.noFavouritesMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textTheme.bodySmall?.color,
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
                    locale: Localizations.localeOf(context).languageCode,
                    otherText: "Other",
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
                        hintText: AppLocalizations.of(
                          context,
                        )!.searchYourRecipes,
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
                      // Show "no matching recipes" if search returns empty
                      if (state.displayRecipes.isEmpty &&
                          state.searchQuery.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No matching recipes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
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
      ),
    );
  }

  Widget _buildGuestFavouritesView(BuildContext context, ThemeData theme) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.favouritesTitle,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.red600.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 64,
                  color: AppColors.red600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.loginRequiredTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: theme.textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                loc.loginRequiredFavorites,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SingupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    loc.signUp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
