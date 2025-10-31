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
      appBar: AppBar(title: Text('My Favourite Recipes')),
      backgroundColor: const Color(0xFFFDF8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SearchBarWidget(),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                        title: "Traditional",
                        subtitle: "5 recipes",
                        imagePaths: ['assets/images/recipes/bastilla.png'],
                        isActive: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: traditionalRecipes
                      .map((r) => RecipeCard(recipe: r))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
