import 'package:flutter/material.dart';
import '../../common/constants.dart';

class ChefCardWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isOnFire; // New attribute for premium feature

  const ChefCardWidget({
    Key? key,
    required this.name,
    this.imageUrl,
    this.onTap,
    this.isOnFire = false, // Default is false, i.e., not activated
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: isOnFire
                      ? Border.all(
                          color: AppColors.red600,
                          width: 4,
                        ) // Red border if isOnFire is true
                      : null,
                  borderRadius: BorderRadius.circular(360), // Circular border
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageUrl != null
                      ? (imageUrl!.startsWith('http')
                            ? NetworkImage(imageUrl!) as ImageProvider
                            : AssetImage(imageUrl!))
                      : const AssetImage('assets/images/chef.png'),
                ),
              ),
              if (isOnFire) ...[
                // Fire icon placed just below the image
                Positioned(
                  bottom: -0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF8E8E),
                          Color(0xFFFFAA6B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
