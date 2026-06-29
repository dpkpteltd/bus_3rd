import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The spinning bus-wheel loader from the splash screen.
class LoadingWheel extends StatefulWidget {
  const LoadingWheel({super.key, this.size = 130});
  final double size;

  @override
  State<LoadingWheel> createState() => _LoadingWheelState();
}

class _LoadingWheelState extends State<LoadingWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1050))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _WheelPainter(),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    // Outer tyre.
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF0E0E0E));
    canvas.drawCircle(
        c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..color = const Color(0xFF2B2B2B));

    // Hub gradient.
    canvas.drawCircle(
      c,
      r - 23,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF5C5C5C), Color(0xFF2C2C2C)],
        ).createShader(Rect.fromCircle(center: c, radius: r - 23)),
    );

    // Spokes.
    final spoke = Paint()..color = const Color(0xFF1A1A1A);
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * pi / 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3.5, -22, 7, 44),
          const Radius.circular(3),
        ),
        spoke,
      );
      canvas.restore();
    }

    // Red centre cap.
    canvas.drawCircle(c, 18, Paint()..color = AppColors.red);
    // Amber valve dot near the top.
    canvas.drawCircle(Offset(c.dx, 11), 4.5, Paint()..color = AppColors.amber);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
