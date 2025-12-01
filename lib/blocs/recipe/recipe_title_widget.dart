import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecipeTitleWidget extends StatelessWidget {
  final String title;

  const RecipeTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Icon(LucideIcons.heart, size: 32, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
