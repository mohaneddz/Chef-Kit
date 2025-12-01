import 'package:chefkit/common/constants.dart';
import 'package:chefkit/data/examples/category_data.dart';
import 'package:chefkit/data/examples/recipe_data.dart';
import 'package:chefkit/blocs/favourites/collection_card.dart';
import 'package:chefkit/blocs/favourites/recipe_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Recipe> selectedRecipes =
        categories[_selectedIndex]['recipes'] as List<Recipe>;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.favorite, size: 52, color: Color(0xFFFF6B6B)),
        ),
        title: Column(
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
              SearchBarWidget(hintText: "Search Your Recipes..."),
              const SizedBox(height: 25),
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> categoryData = entry.value;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: CollectionCard(
                          title: categoryData['title'],
                          subtitle: categoryData['subtitle'],
                          imagePaths: List<String>.from(
                            categoryData['imagePaths'],
                          ),
                          isActive: _selectedIndex == index,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Divider(
                color: Colors.grey,
                thickness: 0.6,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  int crossAxisCount;

                  if (availableWidth < 250) {
                    crossAxisCount = 1;
                  } else if (availableWidth < 540) {
                    crossAxisCount = 2;
                  } else if (availableWidth < 740) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 4;
                  }

                  return Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 0,
                      alignment: WrapAlignment.center,
                      children: selectedRecipes.map((r) {
                        return SizedBox(
                          width: crossAxisCount == 1
                              ? availableWidth * 0.8
                              : (availableWidth / crossAxisCount) - 20,
                          child: RecipeCard(recipe: r),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
