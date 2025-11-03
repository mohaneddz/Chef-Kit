import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final Color shadowColor;
  final double elevation;
  final double stratProportion;
  final double endProportion;
  final double adjustment;
  final bool isReversed;

  TrianglePainter({
    this.color,
    this.gradient,
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    this.adjustment = 1,
    required this.stratProportion,
    required this.endProportion,
    this.isReversed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    if (isReversed) {
      path = Path()
        ..moveTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..lineTo(size.width * adjustment, size.height * endProportion)
        ..lineTo(size.width, size.height * endProportion)
        ..close();
    } else {
      path = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * stratProportion)
        ..lineTo(size.width * adjustment, size.height * stratProportion)
        ..lineTo(0, size.height * endProportion)
        ..close();
    }

    canvas.drawShadow(path, shadowColor, elevation, false);

    final paint = Paint();
    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = color ?? Colors.orange;
    }

    // Draw shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.stratProportion != stratProportion ||
        oldDelegate.endProportion != endProportion ||
        oldDelegate.adjustment != adjustment;
  }
}
