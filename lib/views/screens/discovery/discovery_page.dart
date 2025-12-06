import 'package:chefkit/views/screens/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import '../../../blocs/discovery/discovery_bloc.dart';
import '../../../blocs/discovery/discovery_state.dart';
import '../../../blocs/discovery/discovery_events.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/section_header_widget.dart';
import '../../widgets/profile/chef_card_widget.dart';
import '../../widgets/recipe/recipe_card_widget.dart';
import '../../widgets/recipe/seasonal_item_widget.dart';
import 'all_chefs_page.dart';
import '../profile/chef_profile_public_page.dart';
import 'all_hot_recipes_page.dart';
import 'all_seasonal_page.dart';
import '../recipe/recipe_details_page.dart';
import '../recipe/item_page.dart';
import '../../../common/constants.dart';

class RecipeDiscoveryScreen extends StatefulWidget {
  const RecipeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecipeDiscoveryScreen> createState() => _RecipeDiscoveryScreenState();
}

class _RecipeDiscoveryScreenState extends State<RecipeDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(LoadDiscovery());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.discoverRecipes,
                style: const TextStyle(
                  color: Color(0xFF1D1617),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.findYourNextFavoriteMeal,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'LeagueSpartan',
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, top: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.error(state.error!)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Trigger reload of all discovery data
              context.read<DiscoveryBloc>().add(LoadDiscovery());
              // Wait for the state to finish loading
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.red600,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SearchBarWidget(
                    hintText: AppLocalizations.of(
                      context,
                    )!.searchRecipesOrChefs,
                  ),
                  const SizedBox(height: 30),
                  SectionHeaderWidget(
                    title: AppLocalizations.of(context)!.chefs,
                    onSeeAllPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllChefsPage()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final chef in state.chefsOnFire) ...[
                          ChefCardWidget(
                            name: chef.name,
                            imageUrl: chef.imageUrl,
                            isOnFire: chef.isOnFire,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChefProfilePublicPage(chefId: chef.id),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SectionHeaderWidget(
                    title: AppLocalizations.of(context)!.hotRecipes,
                    onSeeAllPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllHotRecipesPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // Decrease aspect ratio to increase tile height and prevent overflow
                      childAspectRatio: 0.82,
                    ),
                    itemCount: state.hotRecipes.length.clamp(0, 4),
                    itemBuilder: (context, index) {
                      final recipe = state.hotRecipes[index];
                      return RecipeCardWidget(
                        title: recipe.name,
                        subtitle: recipe.description,
                        imageUrl: recipe.imageUrl,
                        isFavorite: recipe.isFavorite,
                        heroTag: 'recipe_${recipe.id}',
                        onFavoritePressed: () => context
                            .read<DiscoveryBloc>()
                            .add(ToggleDiscoveryRecipeFavorite(recipe.id)),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      RecipeDetailsPage(
                                        recipeId: recipe.id,
                                        recipeName: recipe.name,
                                        recipeDescription: recipe.description,
                                        recipeImageUrl: recipe.imageUrl,
                                        recipePrepTime: recipe.prepTime,
                                        recipeCookTime: recipe.cookTime,
                                        recipeCalories: recipe.calories,
                                        recipeServingsCount:
                                            recipe.servingsCount,
                                        recipeIngredients: recipe.ingredients,
                                        recipeInstructions: recipe.instructions,
                                        recipeTags: recipe.tags,
                                        initialFavorite: recipe.isFavorite,
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(0.8, 0.0);
                                    const end = Offset.zero;
                                    final curved = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutQuart,
                                    );

                                    return FadeTransition(
                                      opacity: curved,
                                      child: SlideTransition(
                                        position: Tween(
                                          begin: begin,
                                          end: end,
                                        ).animate(curved),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 350,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SectionHeaderWidget(
                    title: AppLocalizations.of(context)!.seasonalDelights,
                    onSeeAllPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllSeasonalPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (final recipe in state.seasonalRecipes) ...[
                        SeasonalItemWidget(
                          title: recipe.name,
                          subtitle: recipe.description,
                          imageUrl: recipe.imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemPage(
                                  title: recipe.name,
                                  imagePath: recipe.imageUrl,
                                  servings: AppLocalizations.of(
                                    context,
                                  )!.servings(recipe.servingsCount.toString()),
                                  calories: AppLocalizations.of(
                                    context,
                                  )!.calories(recipe.calories.toString()),
                                  time: AppLocalizations.of(context)!.minutes(
                                    (recipe.prepTime + recipe.cookTime)
                                        .toString(),
                                  ),
                                  ingredients: recipe.ingredients,
                                  tags: recipe.tags,
                                  recipeText: recipe.instructions.join('\n'),
                                  initialFavorite: recipe.isFavorite,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 30),
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
