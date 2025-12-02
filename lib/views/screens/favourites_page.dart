import 'package:chefkit/common/constants.dart';
import 'package:chefkit/data/examples/category_data.dart';
import 'package:chefkit/data/examples/recipe_data.dart';
import 'package:chefkit/blocs/favourites/collection_card.dart';
import 'package:chefkit/blocs/home/recipe_card_widget.dart';
import 'package:chefkit/views/screens/item_page.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  static const int _multiplier = 1000; // For simulating infinite scroll

  @override
  void initState() {
    super.initState();
    // Start at a large middle offset so user can scroll both directions
    final initialPage = _multiplier * categories.length + _selectedIndex;
    _pageController = PageController(
      viewportFraction: 0.55,
      initialPage: initialPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryTap(int pageIndex) {
    final realIndex = pageIndex % categories.length;
    setState(() {
      _selectedIndex = realIndex;
    });
    // Animate directly to the tapped page
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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
              SizedBox(
                height: 130,
                child: PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final realIndex = index % categories.length;
                    final categoryData = categories[realIndex];
                    return GestureDetector(
                      onTap: () => _onCategoryTap(index),
                      child: AnimatedScale(
                        scale: _selectedIndex == realIndex ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 200),
                        child: CollectionCard(
                          title: categoryData['title'],
                          subtitle: categoryData['subtitle'],
                          imagePaths: List<String>.from(
                            categoryData['imagePaths'],
                          ),
                          isActive: _selectedIndex == realIndex,
                        ),
                      ),
                    );
                  },
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
                      runSpacing: 16,
                      alignment: WrapAlignment.start,
                      children: selectedRecipes.map((r) {
                        return SizedBox(
                          width:
                              (availableWidth - (crossAxisCount - 1) * 16) /
                              crossAxisCount,
                          child: RecipeCardWidget(
                            title: r.name,
                            subtitle: r.category,
                            imageUrl: r.imagePath,
                            isFavorite: r.isFavorite,
                            onFavoritePressed: () {
                              setState(() {
                                r.isFavorite = !r.isFavorite;
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemPage(
                                    title: r.name,
                                    imagePath: r.imagePath,
                                    servings: r.servings,
                                    calories: r.calories,
                                    time: '${r.duration} min',
                                    ingredients: r.ingredients,
                                    tags: r.tags,
                                    recipeText: r.recipeText,
                                    initialFavorite: r.isFavorite,
                                  ),
                                ),
                              );
                            },
                          ),
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
