import 'package:flutter/material.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionHeaderWidget({
    Key? key,
    required this.title,
    this.onSeeAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        GestureDetector(
          onTap: onSeeAllPressed,
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFFF5D69),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
