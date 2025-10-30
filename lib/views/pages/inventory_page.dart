import 'package:chefkit/common/app_colors.dart';
import 'package:chefkit/views/widgets/ingredient_card.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: 144,
              height: 173,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 144,
                    height: 117,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
