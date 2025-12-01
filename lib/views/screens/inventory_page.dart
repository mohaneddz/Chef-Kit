import 'package:chefkit/common/constants.dart';
import 'package:chefkit/blocs/inventory/ingredient_card.dart';
import 'package:chefkit/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
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
      "type": "Vegetables",
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
  ];

  // Current types of ingredients !
  final List<String> ingredientTypes = [
    "All",
    "Protein",
    "Vegetables",
    "Spices",
    "Spices",
  ];

  int selectedType = 0;

  void _updateIngredientType(value) {
    selectedType = value;
    setState(() {});
  }

  List<Map<String, String>> get filteredIngredients {
    if (selectedType == 0) return ingredients;
    String selected = ingredientTypes[selectedType];
    return ingredients.where((item) => item["type"] == selected).toList();
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

  Widget availabilityCard({
    required Color borderColor,
    required Color gradientColor1,
    required Color gradientColor2,
    required Color textColor,
    required String text,
    required Widget icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientColor1, gradientColor2],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon,
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: "LeagueSpartan",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 72,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Image.asset("assets/images/list-ingredients.png", width: 52),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Kitchen Inventory",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Manage your ingredients",
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
              headerText(
                title: "Available Ingredients",
                subtitle: "Your current pantry items",
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  availabilityCard(
                    borderColor: AppColors.success1.withOpacity(0.3),
                    gradientColor1: AppColors.success1.withOpacity(0.2),
                    gradientColor2: AppColors.success2.withOpacity(0.3),
                    textColor: AppColors.green,
                    text: "8 Available",
                    icon: Image.asset(
                      "assets/images/package_icon.png",
                      width: 12,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  availabilityCard(
                    borderColor: const Color(0xFFFD5D69).withOpacity(0.3),
                    gradientColor1: const Color(0xFFFD5D69).withOpacity(0.2),
                    gradientColor2: AppColors.orange.withOpacity(0.2),
                    textColor: AppColors.red600,
                    text: "+100 Total Items",
                    icon: Image.asset(
                      "assets/images/star_icon.png",
                      width: 12,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Current ingredients View
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
                  return IngredientCard(
                    imageUrl: item["imageUrl"]!,
                    ingredientName: item["name"]!,
                    ingredientType: item["type"]!,
                  );
                },
              ),
              // Show more
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 0),
                        padding: EdgeInsets.all(0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: Text(
                        "Show more",
                        style: TextStyle(
                          color: AppColors.browmpod,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "LeagueSpartan",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_downward,
                        size: 24,
                        color: Color(0xFF8F4A4C),
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              headerText(
                title: "Browse all the ingredients ",
                subtitle: "Find what you need ?",
              ),
              const SizedBox(height: 30),
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
              // Browse ingredients
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 180,
                ),
                itemCount: filteredIngredients.length,
                itemBuilder: (context, index) {
                  final item = filteredIngredients[index];
                  return IngredientCard(
                    imageUrl: item["imageUrl"]!,
                    ingredientName: item["name"]!,
                    ingredientType: item["type"]!,
                    addIngredient: true,
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
