import 'package:flutter/material.dart';
import '../../common/constants.dart';

class ChefCardWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isOnFire;

  const ChefCardWidget({
    Key? key,
    required this.name,
    this.imageUrl,
    this.onTap,
    this.isOnFire = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Gradient border if on fire, transparent if not
              gradient: isOnFire
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: isOnFire
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF5E62).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 34, 
                backgroundColor: Colors.grey[100],
                backgroundImage: imageUrl != null
                    ? (imageUrl!.startsWith('http')
                        ? NetworkImage(imageUrl!) as ImageProvider
                        : AssetImage(imageUrl!))
                    : const AssetImage('assets/images/chef.png'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: isOnFire ? Colors.black : Colors.grey[700],
            ),
          ),
          if (isOnFire)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, size: 10, color: Color(0xFFFF5E62)),
                  SizedBox(width: 2),
                  Text(
                    "TRENDING",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFFF5E62)),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}