import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:chefkit/blocs/recipe/recipe_widget.dart';

class ItemPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final String servings;
  final String calories;
  final String time;
  final List<String> ingredients;
  final List<String> tags;
  final String recipeText;
  final bool initialFavorite;

  const ItemPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.servings,
    required this.calories,
    required this.time,
    required this.ingredients,
    required this.tags,
    required this.recipeText,
    this.initialFavorite = false,
  });

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialFavorite;
  }

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
        title: Text(
          widget.title,
          style: const TextStyle(
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
                  title: widget.title,
                  imagePath: widget.imagePath,
                  isFavorite: isFavorite,
                  onFavoriteTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  servings: widget.servings,
                  calories: widget.calories,
                  time: widget.time,
                  ingredients: widget.ingredients,
                  tags: widget.tags,
                  recipeText: widget.recipeText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
