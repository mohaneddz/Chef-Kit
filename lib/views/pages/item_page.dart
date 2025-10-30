import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:chefkit/views/widgets/recipe/recipe_widget.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 200, 200, 200),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Focused Recipe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image Card
                RecipeWidget(
                  title: 'Couscous',
                  imagePath: 'assets/images/couscous.png',
                  isFavorite: isFavorite,
                  onFavoriteTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  servings: '20 g',
                  calories: '300 Kcal',
                  time: '20 m',
                  ingredients: [
                    'Potatoes',
                    'Tomatoes',
                    'Carrots',
                    'Seasonings',
                    'Serrano',
                    'Texano',
                  ],
                  tags: ['Seafood', 'Herbs', 'Beef', '+2'],
                  recipeText:
                      'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem ipsum.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
