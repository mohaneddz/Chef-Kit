import 'package:flutter/material.dart';

class FavouritesHeader extends StatelessWidget {
  const FavouritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Favourites",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Find Your Saved Recipes",
          style: TextStyle(
            color: Color(0xFF4A5565),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "LeagueSpartan",
          ),
        ),
      ],
    );
  }
}
