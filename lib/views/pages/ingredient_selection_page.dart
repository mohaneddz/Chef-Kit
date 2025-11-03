import 'package:chefkit/common/app_colors.dart';
import 'package:chefkit/views/pages/recipe_loading_page.dart';
import 'package:chefkit/views/widgets/ingredient_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class IngredientSelectionPage extends StatefulWidget {
  const IngredientSelectionPage({super.key});

  @override
  State<IngredientSelectionPage> createState() =>
      _IngredientSelectionPageState();
}

class _IngredientSelectionPageState extends State<IngredientSelectionPage> {
  // Temporary mock ingredient data
  final List<Map<String, String>> ingredients = [
    {
      "imageUrl": "assets/images/escalope.png",
      "name": "Escalope",
      "type": "Protein",
    },
    {
      "imageUrl": "assets/images/tomato.png",
      "name": "Tomato",
      "type": "Vegetable",
    },
    {
      "imageUrl": "assets/images/potato.png",
      "name": "Potato",
      "type": "Vegetable",
    },
    {
      "imageUrl": "assets/images/paprika.png",
      "name": "Paprika",
      "type": "Spices",
    },
    {
      "imageUrl": "assets/images/escalope.png",
      "name": "Chicken",
      "type": "Protein",
    },
    {
      "imageUrl": "assets/images/tomato.png",
      "name": "Onion",
      "type": "Vegetable",
    },
    {
      "imageUrl": "assets/images/potato.png",
      "name": "Carrot",
      "type": "Vegetable",
    },
    {
      "imageUrl": "assets/images/paprika.png",
      "name": "Cumin",
      "type": "Spices",
    },
  ];

  // Current types of ingredients !
  final List<String> ingredientTypes = [
    "All",
    "Protein",
    "Vegetables",
    "Spices",
  ];

  int selectedType = 0;
  Set<String> selectedIngredients = {};

  void _updateIngredientType(value) {
    selectedType = value;
    setState(() {});
  }

  void _toggleIngredientSelection(String ingredientName) {
    setState(() {
      if (selectedIngredients.contains(ingredientName)) {
        selectedIngredients.remove(ingredientName);
      } else {
        selectedIngredients.add(ingredientName);
      }
    });
  }

  Widget headerText({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Ingredients",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Choose what you have available",
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
              const SearchBarWidget(),
              const SizedBox(height: 25),
              
              // Selected count indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red600.withOpacity(0.1),
                      AppColors.orange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.red600.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.red600,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "${selectedIngredients.length} ingredient${selectedIngredients.length != 1 ? 's' : ''} selected",
                      style: TextStyle(
                        color: AppColors.red600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              headerText(
                title: "Available Ingredients",
                subtitle: "Tap to select ingredients",
              ),
              const SizedBox(height: 30),
              
              // Category tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 30,
                  children: List.generate(
                    ingredientTypes.length,
                    (index) => TextButton(
                      onPressed: () => _updateIngredientType(index),
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 0),
                        padding: EdgeInsets.all(0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        ingredientTypes.elementAt(index),
                        style: selectedType == index
                            ? TextStyle(
                                color: AppColors.red600,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: "LeagueSpartan",
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.red600,
                                decorationThickness: 2,
                              )
                            : TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: "LeagueSpartan",
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Ingredients grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 180,
                ),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final item = ingredients[index];
                  final isSelected = selectedIngredients.contains(item["name"]!);
                  
                  return GestureDetector(
                    onTap: () => _toggleIngredientSelection(item["name"]!),
                    child: Stack(
                      children: [
                        IngredientCard(
                          imageUrl: item["imageUrl"]!,
                          ingredientName: item["name"]!,
                          ingredientType: item["type"]!,
                        ),
                        // Selection overlay
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppColors.red600.withOpacity(0.3),
                                border: Border.all(
                                  color: AppColors.red600,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.red600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: selectedIngredients.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to loading and then results
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeLoadingPage(
                      selectedIngredients: selectedIngredients.toList(),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.red600,
              icon: Icon(Icons.search, color: Colors.white),
              label: Text(
                "Find Recipes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
