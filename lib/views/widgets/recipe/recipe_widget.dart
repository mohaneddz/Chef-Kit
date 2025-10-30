import 'package:flutter/material.dart';
import 'package:chefkit/views/widgets/ingredients/ingredients_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_image_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_title_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_info_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_tags_widget.dart';
import 'package:chefkit/views/widgets/recipe/recipe_text_widget.dart';

class RecipeWidget extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final String servings;
  final String calories;
  final String time;
  final List<String> ingredients;
  final List<String> tags;
  final String recipeText;

  const RecipeWidget({
    super.key,
    this.onFavoriteTap,
    this.isFavorite = false,
    required this.tags,
    required this.time,
    required this.title,
    required this.servings,
    required this.calories,
    required this.imagePath,
    required this.recipeText,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 80),
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Top image border
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                "assets/images/recipe_border.png",
                fit: BoxFit.cover,
                height: 210,
                width: double.infinity,
              ),
            ),

            // White container directly connected to image (no gap)
            Container(
              margin: const EdgeInsets.only(top: 199),
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecipeTitleWidget(title: title),
                    const SizedBox(height: 24),

                    RecipeInfoWidget(
                      servings: servings,
                      calories: calories,
                      time: time,
                    ),
                    const SizedBox(height: 24),

                    IngredientsWidget(ingredients: ingredients),
                    const SizedBox(height: 8),

                    RecipeTagsWidget(tags: tags),
                    const SizedBox(height: 8),

                    RecipeTextWidget(recipeText: recipeText),
                  ],
                ),
              ),
            ),

            // Recipe image on top
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: RecipeImageWidget(
                imagePath: imagePath,
                onFavoriteTap: onFavoriteTap,
                isFavorite: isFavorite,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
