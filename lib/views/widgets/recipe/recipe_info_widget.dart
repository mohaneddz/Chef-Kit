import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecipeInfoWidget extends StatelessWidget {
  final String servings;
  final String calories;
  final String time;

  const RecipeInfoWidget({
    super.key,
    required this.servings,
    required this.calories,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildInfoItem(LucideIcons.scale, servings, 'Serving')),
        SizedBox(
          width: 12,
          child: VerticalDivider(color: Colors.grey[400], thickness: 1),
        ),
        Expanded(
          child: _buildInfoItem(LucideIcons.flame, calories, 'Calories'),
        ),
        SizedBox(
          width: 12,
          child: VerticalDivider(color: Colors.grey[400], thickness: 1),
        ),
        Expanded(child: _buildInfoItem(LucideIcons.clock, time, 'Time')),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
