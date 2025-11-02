import 'package:chefkit/common/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/discovery/section_header_widget.dart';
import '../widgets/discovery/chef_card_widget.dart';
import '../widgets/discovery/recipe_card_widget.dart';
import '../widgets/discovery/seasonal_item_widget.dart';
import './all_chefs_page.dart';
import './all_hot_recipes_page.dart';
import './all_seasonal_page.dart';

class RecipeDiscoveryScreen extends StatelessWidget {
  const RecipeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.explore,
            size: 52,
            color: Color(0xFFFF6B6B),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discover Recipes",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Find your next favorite meal",
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
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              // Search bar
              const SearchBarWidget(hintText: "Search Recipes or Chefs",),
              const SizedBox(height: 25),

              // Chefs ON Fire
              SectionHeaderWidget(
                title: 'Chefs ON Fire',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllChefsPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChefCardWidget(
                      name: 'G. Ramsay',
                      imageUrl: 'assets/images/chefs/chef_1.png',
                      isOnFire: true,
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                    const SizedBox(width: 12),
                    ChefCardWidget(
                      name: 'Jamie Oliver',
                      imageUrl: 'assets/images/chefs/chef_2.png',
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                    const SizedBox(width: 12),
                    ChefCardWidget(
                      name: 'M. Bottura',
                      imageUrl: 'assets/images/chefs/chef_3.png',
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                    const SizedBox(width: 12),
                    ChefCardWidget(
                      name: 'A. Ducasse',
                      imageUrl: 'assets/images/chefs/chef_3.png',
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                    const SizedBox(width: 12),
                    ChefCardWidget(
                      name: 'J. Robuchon',
                      imageUrl: 'assets/images/chefs/chef_1.png',
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                    const SizedBox(width: 12),
                    ChefCardWidget(
                      name: 'T. Keller',
                      imageUrl: 'assets/images/chefs/chef_2.png',
                      onTap: () {
                        // TODO: Navigate to chef profile
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Hot Recipes
              SectionHeaderWidget(
                title: 'Hot Recipes',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllHotRecipesPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Mahjouba',
                      subtitle: 'Authentic Algerian\nClassic',
                      imageUrl: 'assets/images/Mahjouba.jpeg',
                      onTap: () {
                        // TODO: Navigate to recipe details
                      },
                      onFavoritePressed: () {
                        // TODO: Toggle favorite
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Couscous/ Berbousha',
                      subtitle: 'steamed and dried semolina flour',
                      imageUrl: 'assets/images/couscous.png',
                      onTap: () {
                        // TODO: Navigate to recipe details
                      },
                      onFavoritePressed: () {
                        // TODO: Toggle favorite
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Barkoukes',
                      subtitle: 'Traditional Soup',
                      imageUrl: 'assets/images/Barkoukes.jpg',
                      onTap: () {
                        // TODO: Navigate to recipe details
                      },
                      onFavoritePressed: () {
                        // TODO: Toggle favorite
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Escalope',
                      subtitle: 'Delicious & Crispy',
                      imageUrl: 'assets/images/escalope.png',
                      onTap: () {
                        // TODO: Navigate to recipe details
                      },
                      onFavoritePressed: () {
                        // TODO: Toggle favorite
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Seasonal Delights
              SectionHeaderWidget(
                title: 'Seasonal Delights',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllSeasonalPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              SeasonalItemWidget(
                title: 'Barkoukes/ Eich',
                subtitle: 'Soup',
                imageUrl: 'assets/images/Barkoukes.jpg',
                onTap: () {
                  // TODO: Navigate to seasonal recipe
                },
              ),
              const SizedBox(height: 16),
              SeasonalItemWidget(
                title: 'Strawberry Salad',
                subtitle: 'with Balsamic Glaze',
                imageUrl: 'assets/images/tomato.png',
                onTap: () {
                  // TODO: Navigate to seasonal recipe
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}