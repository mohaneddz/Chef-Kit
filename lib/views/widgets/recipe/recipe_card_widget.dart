import 'package:flutter/material.dart';
import 'dart:ui';

class RecipeCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;

  const RecipeCardWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
    this.onFavoritePressed,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Let parent constraints (GridView tile) dictate height to avoid overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D1617).withOpacity(0.07),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: AssetImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/recipe.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoritePressed,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            height: 36,
                            width: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFavorite ? const Color(0xFFFF5D69) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Use Padding with IntrinsicHeight to prevent overflow
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(
                        "30 min",
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}