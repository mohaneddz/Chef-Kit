import 'package:chefkit/data/recipe_data.dart';
import 'package:chefkit/views/pages/item_page.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              width: 170,
              height: 140,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.2,
                    ),
                    blurRadius:
                        15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 34),
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.category,
                    style: const TextStyle(
                      color: Color(0xFFC65B42),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.duration} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 1,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        recipe.isReady ? Icons.check_circle : Icons.cancel,
                        color: recipe.isReady ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.isReady ? 'Ready' : 'Missing',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: recipe.isReady ? Colors.green : Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              height: 100,
              child: ClipRRect(
                child: Image.asset(recipe.imagePath, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}