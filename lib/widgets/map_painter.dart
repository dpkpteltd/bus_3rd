import 'dart:math';

import 'package:flutter/material.dart';

/// A deliberately fake "live map". Draws stylised roads, a sea, a few stops, and
/// a bus marker that wanders along a silly parametric path. No real map data,
/// no API keys, no location access — it's all painted by hand.
class FakeMapPainter extends CustomPainter {
  FakeMapPainter({required this.t, required this.isDark});

  /// Animation progress, 0..1, looping.
  final double t;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final land = Paint()
      ..color = isDark ? const Color(0xFF1B2A2A) : const Color(0xFFE8F3F1);
    canvas.drawRect(Offset.zero & size, land);

    // A "sea" the bus keeps driving into.
    final sea = Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.55);
    final seaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.62, size.width * 0.5,
          size.height * 0.5),
      const Radius.circular(40),
    );
    canvas.drawRRect(seaRect, sea);
    _label(canvas, 'SEA', Offset(size.width * 0.78, size.height * 0.86),
        const Color(0xFF0277BD));

    // Roads.
    final road = Paint()
      ..color = isDark ? const Color(0xFF3A4A4A) : const Color(0xFFB7C8C5)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.28), road);
    canvas.drawLine(Offset(size.width * 0.25, 0),
        Offset(size.width * 0.28, size.height), road);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.55, size.height), road);

    // Stop dots.
    final stopPaint = Paint()..color = const Color(0xFF00897B);
    for (final p in [
      Offset(size.width * 0.25, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.28),
      Offset(size.width * 0.28, size.height * 0.8),
    ]) {
      canvas.drawCircle(p, 7, stopPaint);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }

    // The bus, wandering on a Lissajous curve (so it loops, circles and dips
    // into the sea).
    final angle = t * 2 * pi;
    final cx = size.width * (0.5 + 0.32 * sin(angle * 2));
    final cy = size.height * (0.5 + 0.34 * sin(angle * 3 + 0.6));
    final heading = atan2(
      cos(angle * 3 + 0.6) * 3,
      cos(angle * 2) * 2,
    );
    _drawBus(canvas, Offset(cx, cy), heading);
  }

  void _drawBus(Canvas canvas, Offset pos, double heading) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(heading);
    const w = 38.0;
    const h = 20.0;
    final body = Paint()..color = const Color(0xFFFFB300);
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-w / 2, -h / 2, w, h),
      const Radius.circular(6),
    );
    canvas.drawShadow(Path()..addRRect(rect), Colors.black, 3, false);
    canvas.drawRRect(rect, body);
    // Windows.
    final win = Paint()..color = const Color(0xFF263238);
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2 + 5 + i * 9.5, -h / 2 + 4, 7, 6),
          const Radius.circular(2),
        ),
        win,
      );
    }
    canvas.restore();
  }

  void _label(Canvas canvas, String text, Offset center, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant FakeMapPainter old) =>
      old.t != t || old.isDark != isDark;
}
