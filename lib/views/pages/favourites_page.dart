import 'package:chefkit/data/recipe_data.dart';
import 'package:chefkit/views/widgets/favourites/collection_card.dart';
import 'package:chefkit/views/widgets/favourites/recipe_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Image.asset("assets/images/heart-icon.png", width: 52),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Favourite Recipes",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "See what you have saved",
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SearchBarWidget(),
                const SizedBox(height: 20),
                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: const [
                        CollectionCard(
                          title: "Traditional",
                          subtitle: "5 recipes",
                          imagePaths: [
                            'assets/images/recipes/couscous.png',
                            'assets/images/recipes/hrira.png',
                            'assets/images/recipes/roqaq.png',
                          ],
                          isActive: true,
                        ),
                        CollectionCard(
                          title: "Quick & Easy",
                          subtitle: "1 recipe",
                          imagePaths: ['assets/images/recipes/bastilla.png'],
                          isActive: false,
                        ),
                        CollectionCard(
                          title: "All Saved",
                          subtitle: "5 recipe",
                          imagePaths: [
                            'assets/images/recipes/couscous.png',
                            'assets/images/recipes/hrira.png',
                            'assets/images/recipes/roqaq.png',
                          ],
                          isActive: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.grey,
                  thickness: 0.6,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    spacing: 16,
                    children: traditionalRecipes
                        .map((r) => RecipeCard(recipe: r))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
