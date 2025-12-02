import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/discovery/discovery_bloc.dart';
import '../../blocs/discovery/discovery_state.dart';
import '../../blocs/discovery/discovery_events.dart';
import '../widgets/search_bar_widget.dart';
import '../../blocs/home/section_header_widget.dart';
import '../../blocs/home/chef_card_widget.dart';
import '../../blocs/home/recipe_card_widget.dart';
import '../../blocs/home/seasonal_item_widget.dart';
import 'all_chefs_page.dart';
import 'chef_profile_public_page.dart';
import 'all_hot_recipes_page.dart';
import 'all_seasonal_page.dart';
import 'item_page.dart';

class RecipeDiscoveryScreen extends StatelessWidget {
  const RecipeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
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
              const Text('Discover Recipes', style: TextStyle(color: Color(0xFF1D1617), fontSize: 26, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Text('Find your next favorite meal', style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'LeagueSpartan')),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, top: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
              child: const Icon(Icons.notifications_outlined, size: 24, color: Colors.black),
            ),
          )
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const SearchBarWidget(hintText: 'Search Recipes or Chefs'),
                  const SizedBox(height: 30),
                  SectionHeaderWidget(
                    title: 'Chefs',
                    onSeeAllPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllChefsPage())),
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
                                  builder: (_) => ChefProfilePublicPage(chefId: chef.id),
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
                    title: 'Hot Recipes',
                    onSeeAllPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllHotRecipesPage())),
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
                        title: recipe.title,
                        subtitle: recipe.subtitle,
                        imageUrl: recipe.imageUrl,
                        isFavorite: recipe.isFavorite,
                        onFavoritePressed: () => context.read<DiscoveryBloc>().add(ToggleDiscoveryRecipeFavorite(recipe.id)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemPage(
                                title: recipe.title,
                                imagePath: recipe.imageUrl,
                                servings: '4 servings',
                                calories: '450 Kcal',
                                time: recipe.time,
                                ingredients: const [],
                                tags: recipe.tags,
                                recipeText: 'Recipe details for ${recipe.title} ...',
                                initialFavorite: recipe.isFavorite,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SectionHeaderWidget(
                    title: 'Seasonal Delights',
                    onSeeAllPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSeasonalPage())),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (final recipe in state.seasonalRecipes) ...[
                        SeasonalItemWidget(
                          title: recipe.title,
                          subtitle: recipe.subtitle,
                          imageUrl: recipe.imageUrl,
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}