import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final double elevation;
  final double stratProportion;
  final double endProportion;

  TrianglePainter({
    required this.color,
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    required this.stratProportion,
    required this.endProportion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * stratProportion)
      ..lineTo(0, size.height * endProportion)
      ..close();

    canvas.drawShadow(
      path,
      shadowColor,
      elevation,
      false, // 'transparentOccluder': true if the object itself is transparent
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
