import 'package:chefkit/common/app_colors.dart';
import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> imagePaths;
  final bool isActive;

  const CollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePaths,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 181,
      height: 117,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: AppColors.red600, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFF5F3EF),
            offset: const Offset(-5, -5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.red600 : AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          SizedBox(
            height: 40,
            width: (25.0 * (imagePaths.length - 1)) + 40,
            child: Stack(
              children: List.generate(imagePaths.length, (index) {
                final leftOffset = index * 25.0;
                return Positioned(
                  left: leftOffset,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePaths[index],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
