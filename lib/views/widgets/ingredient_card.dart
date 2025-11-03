import 'package:flutter/material.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({
    super.key,
    required this.imageUrl,
    required this.ingredientName,
    required this.ingredientType,
  });

  final String imageUrl;
  final String ingredientName;
  final String ingredientType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Color(0xFFF5F3EF),
                    offset: Offset(-5, -5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Image positioned at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 15),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Image.asset(
                imageUrl,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fastfood,
                    size: 60,
                    color: Colors.grey[400],
                  );
                },
              ),
            ),
          ),
          // Text and badge at bottom
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ingredientName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  ingredientType,
                  style: TextStyle(
                    color: Color(0xFFC65B42),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Container(
                  width: 86,
                  height: 19,
                  decoration: BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFFB9F8CF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Color(0xFF00C950),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                      Text(
                        "In Stock",
                        style: TextStyle(
                          color: Color(0xFF008236),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
