import '../../common/config.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFFCFCFC), // Very clean off-white
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC), // Matches body
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80, // Taller header for better look
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Discover Recipes",
                style: TextStyle(
                  color: Color(0xFF1D1617),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins', // Changed to match your other fonts
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Find your next favorite meal",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "LeagueSpartan",
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, top: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.notifications_outlined, // Changed to notification icon
                size: 24,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Makes scrolling feel better
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Search bar
              const SearchBarWidget(hintText: "Search Recipes or Chefs"),
              const SizedBox(height: 30),

              // Chefs
              SectionHeaderWidget(
                title: 'Chefs',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllChefsPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none, // Allows shadows to paint outside
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChefCardWidget(
                      name: 'G. Ramsay',
                      imageUrl: 'assets/images/chefs/chef_1.png',
                      isOnFire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChefProfilePublicPage(
                              name: 'G. Ramsay',
                              imageUrl: 'assets/images/chefs/chef_1.png',
                              isOnFire: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ChefCardWidget(
                      name: 'Jamie Oliver',
                      imageUrl: 'assets/images/chefs/chef_2.png',
                      isOnFire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChefProfilePublicPage(
                              name: 'Jamie Oliver',
                              imageUrl: 'assets/images/chefs/chef_2.png',
                              isOnFire: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ChefCardWidget(
                      name: 'M. Bottura',
                      imageUrl: 'assets/images/chefs/chef_3.png',
                      isOnFire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChefProfilePublicPage(
                              name: 'M. Bottura',
                              imageUrl: 'assets/images/chefs/chef_3.png',
                              isOnFire: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ChefCardWidget(
                      name: 'A. Ducasse',
                      imageUrl: 'assets/images/chefs/chef_3.png',
                      isOnFire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChefProfilePublicPage(
                              name: 'A. Ducasse',
                              imageUrl: 'assets/images/chefs/chef_3.png',
                              isOnFire: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ChefCardWidget(
                      name: 'J. Robuchon',
                      imageUrl: 'assets/images/chefs/chef_1.png',
                      isOnFire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChefProfilePublicPage(
                              name: 'J. Robuchon',
                              imageUrl: 'assets/images/chefs/chef_1.png',
                              isOnFire: true,
                            ),
                          ),
                        );
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
              const SizedBox(height: 16),
              // ROW 1
              Row(
                children: [
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Mahjouba',
                      subtitle: 'Algerian Classic',
                      imageUrl: 'assets/images/Mahjouba.jpeg',
                      onTap: () {
                         // Your navigation code...
                         Navigator.push(context, MaterialPageRoute(builder: (context) => ItemPage(
                              title: 'Mahjouba',
                              imagePath: 'assets/images/Mahjouba.jpeg',
                              servings: '4 servings',
                              calories: '450 Kcal',
                              time: '45 min',
                              ingredients: ['Semolina', 'Tomatoes', 'Onions', 'Peppers', 'Spices'],
                              tags: ['Traditional', 'Algerian', 'Savory'],
                              recipeText: 'Mahjouba is a traditional Algerian flatbread...',
                              initialFavorite: false,
                            )));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Couscous',
                      subtitle: 'Steamed semolina',
                      imageUrl: 'assets/images/couscous.png',
                      onTap: () {
                         // Your navigation code...
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ROW 2
              Row(
                children: [
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Barkoukes',
                      subtitle: 'Traditional Soup',
                      imageUrl: 'assets/images/Barkoukes.jpg',
                      onTap: () {
                         // Your navigation code...
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RecipeCardWidget(
                      title: 'Escalope',
                      subtitle: 'Crispy Chicken',
                      imageUrl: 'assets/images/escalope.png',
                      onTap: () {
                         // Your navigation code...
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
              const SizedBox(height: 16),
              SeasonalItemWidget(
                title: 'Barkoukes/ Eich',
                subtitle: 'Soup',
                imageUrl: 'assets/images/Barkoukes.jpg',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              SeasonalItemWidget(
                title: 'Strawberry Salad',
                subtitle: 'with Balsamic Glaze',
                imageUrl: 'assets/images/tomato.png',
                onTap: () {},
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}