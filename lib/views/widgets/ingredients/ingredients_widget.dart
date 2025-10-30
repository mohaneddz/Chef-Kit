import 'package:flutter/material.dart';

class IngredientsWidget extends StatelessWidget {
  final List<String> ingredients;

  const IngredientsWidget({super.key, required this.ingredients});

  static final Map<String, String> _ingredientImages = {
    'potatoes': 'assets/images/ingredients/potatoes.png',
    'tomatoes': 'assets/images/ingredients/tomatoes.png',
    'escalope': 'assets/images/ingredients/escalope.png',
    'courgette': 'assets/images/ingredients/courgette.png',
  };

  static String _getImagePath(String ingredient) {
    final key = ingredient.toLowerCase();
    return _ingredientImages.entries
        .firstWhere(
          (e) => key.contains(e.key),
          orElse: () =>
              const MapEntry('', 'assets/images/ingredients/potatoes.png'),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              const SizedBox(width: 12),
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: ingredients
                  .map(
                    (ingredient) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            _getImagePath(ingredient),
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ingredient,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
