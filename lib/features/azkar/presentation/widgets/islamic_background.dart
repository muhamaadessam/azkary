import 'dart:math' as math;

import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _IslamicPatternPainter(), child: child);
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pattern = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x1F0F6B55);
    const step = 72.0;

    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final center = Offset(x, y);
        canvas.drawCircle(center, 22, pattern);
        canvas.drawCircle(
          center + const Offset(step / 2, step / 2),
          22,
          pattern,
        );
      }
    }

    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33C08A28);
    final dome = Path()
      ..moveTo(size.width * .08, size.height * .98)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .66,
        size.width * .92,
        size.height * .98,
      );
    canvas.drawPath(dome, accent);

    final starCenter = Offset(size.width - 58, 82);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        starCenter,
        starCenter + Offset(math.cos(angle), math.sin(angle)) * 28,
        accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
