import 'package:flutter/material.dart';

class RecipeImageWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const RecipeImageWidget({
    super.key,
    required this.imagePath,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
