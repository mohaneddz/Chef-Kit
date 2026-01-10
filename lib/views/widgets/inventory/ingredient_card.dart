import 'package:chefkit/common/constants.dart';
import 'package:flutter/material.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({
    super.key,
    required this.imageUrl,
    required this.ingredientName,
    required this.ingredientType,
    this.addIngredient = false,
    this.onAdd,
    this.onRemove,
  });

  final String imageUrl;
  final String ingredientName;
  final String ingredientType;
  final bool addIngredient;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight * 0.65;

        return SizedBox(
          width: cardWidth,
          height: constraints.maxHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: isDark ? Color(0xFF2A2A2A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.25),
                      offset: Offset(4, 4),
                      blurRadius: 8,
                    ),
                    if (!isDark)
                      BoxShadow(
                        color: Color(0xFFF5F3EF),
                        offset: Offset(-5, -5),
                        blurRadius: 5,
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
                        offset: Offset(0, 15),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    imageUrl,
                    height: 85,
                    width: 95,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    Text(
                      ingredientName,
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      ingredientType,
                      style: TextStyle(
                        color: Color(0xFFC65B42),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    addIngredient
                        ? GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              width: 86,
                              height: 23,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Color(0xFF0D3D1C)
                                    : Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Color(0xFF22C55E)
                                      : Color(0xFFB9F8CF),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        Icons.add,
                                        color: Colors.white,
                                        size: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Add",
                                    style: TextStyle(
                                      color: isDark
                                          ? Color(0xFF22C55E)
                                          : Color(0xFF008236),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: onRemove,
                            child: Row(
                              children: [
                                Container(
                                  width: 86,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: AppColors.red600.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.red600),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: AppColors.red600,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.delete_outline_outlined,
                                            color: Colors.white,
                                            size: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: AppColors.red600,
                                          fontSize: 12,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
