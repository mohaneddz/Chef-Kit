import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const TagWidget({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 200, 200, 200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
