import 'package:flutter/material.dart';

class GolfLogo extends StatelessWidget {
  final double size;

  const GolfLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100;

    // 1. Container: Squircle Shape (Brand Green #15803d)
    final rectPaint = Paint()..color = const Color(0xFF15803D);
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(22 * scale),
    );
    canvas.drawRRect(rRect, rectPaint);

    // 2. Centered Weather-Golf Hybrid Element
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    // Sun Rays
    final rayCoords = [
      [0.0, -22.0, 0.0, -28.0],
      [0.0, 22.0, 0.0, 28.0],
      [22.0, 0.0, 28.0, 0.0],
      [-22.0, 0.0, -28.0, 0.0],
      [15.5, -15.5, 19.8, -19.8],
      [-15.5, 15.5, -19.8, 19.8],
      [15.5, 15.5, 19.8, 19.8],
      [-15.5, -15.5, -19.8, -19.8],
    ];

    for (var coord in rayCoords) {
      canvas.drawLine(
        Offset(center.dx + coord[0] * scale, center.dy + coord[1] * scale),
        Offset(center.dx + coord[2] * scale, center.dy + coord[3] * scale),
        yellowPaint,
      );
    }

    // Sun-Ball Body
    final bodyPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 16 * scale, bodyPaint);

    // Refined Dimples
    final dimplePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final dimpleCoords = [
      [0.0, 0.0],
      [-6.0, -4.0],
      [6.0, -4.0],
      [-5.0, 6.0],
      [5.0, 6.0],
    ];

    for (var coord in dimpleCoords) {
      canvas.drawCircle(
        Offset(center.dx + coord[0] * scale, center.dy + coord[1] * scale),
        1.5 * scale,
        dimplePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
