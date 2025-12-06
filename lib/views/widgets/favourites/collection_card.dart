import 'package:chefkit/common/constants.dart';
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
            color: Colors.black.withValues(alpha: 0.25),
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
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.red600 : AppColors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
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
                    child: _buildImage(imagePaths[index]),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
          );
        },
      );
    }
    return Image.asset(
      path,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 40,
          height: 40,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
        );
      },
    );
  }
}
