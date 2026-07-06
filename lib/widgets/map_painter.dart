import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A deliberately fake, illustrated "live map" of Singapore (+ Pulau Tekong and
/// Sentosa). Everything is hand-drawn — coastline, ~28 towns with Singlish
/// sub-labels, MRT-style lines, rivers, trees, a parody Merlion and a bumboat.
/// No real map data, API keys, or location.
///
/// The static scene is recorded once into a [ui.Picture] (so the labels aren't
/// re-laid-out every animation frame); only the bus is redrawn per frame.
class SgMapPainter extends CustomPainter {
  SgMapPainter({
    required this.busPos,
    required this.heading,
    required this.scale,
    required this.camCenter,
    required this.propellerSpin,
    required this.grabbed,
  });

  final Offset busPos;
  final double heading;
  final double scale;
  final Offset camCenter;
  final double propellerSpin;
  final bool grabbed;

  static const Size world = Size(1400, 1000);

  /// Bounding box the view fits to (includes JB up north so it's on-screen but
  /// doesn't overflow). The bus still roams the main island.
  static const Rect islandBounds = Rect.fromLTRB(110, 120, 970, 700);

  // ---- colours ----
  static const _sea = Color(0xFF9FD4EA);
  static const _seaWave = Color(0xFF74B8D8);
  static const _land = Color(0xFFF3ECD9);
  static const _coast = Color(0xFFCBB892);
  static const _road = Color(0xFFC3A874);
  static const _river = Color(0xFF8CCBE8);

  // ---- coastlines ----
  static const List<Offset> _outline = [
    Offset(110, 470), Offset(180, 380), Offset(260, 320), Offset(360, 268),
    Offset(445, 235), Offset(525, 240), Offset(610, 250), Offset(695, 270),
    Offset(780, 300), Offset(855, 350), Offset(925, 410), Offset(968, 470),
    Offset(930, 535), Offset(860, 575), Offset(775, 615), Offset(690, 650),
    Offset(620, 678), Offset(555, 685), Offset(495, 668), Offset(435, 640),
    Offset(375, 622), Offset(315, 588), Offset(255, 560), Offset(195, 522),
    Offset(140, 500),
  ];
  static const List<Offset> _tekongOutline = [
    Offset(1010, 300), Offset(1065, 220), Offset(1150, 178), Offset(1240, 172),
    Offset(1310, 210), Offset(1352, 292), Offset(1352, 386), Offset(1306, 470),
    Offset(1224, 516), Offset(1136, 508), Offset(1058, 462), Offset(1014, 384),
  ];
  static const List<Offset> _sentosaOutline = [
    Offset(430, 726), Offset(485, 712), Offset(548, 720), Offset(566, 754),
    Offset(512, 788), Offset(448, 776),
  ];

  // Northern landmass — JB, across the Causeway (always jammed).
  static const List<Offset> _jbOutline = [
    Offset(180, 40), Offset(320, 12), Offset(470, 4), Offset(630, 10),
    Offset(780, 20), Offset(910, 48), Offset(1000, 92), Offset(940, 138),
    Offset(800, 152), Offset(650, 156), Offset(500, 152), Offset(360, 142),
    Offset(250, 118), Offset(168, 82),
  ];

  static final Path island = _smoothClosed(_outline);
  static final Path tekong = _smoothClosed(_tekongOutline);
  static final Path sentosa = _smoothClosed(_sentosaOutline);
  static final Path jb = _smoothClosed(_jbOutline);

  /// The northern JB zone. Drag the bus in here and it snaps to the Causeway and
  /// gets stuck in the jam until dragged back out.
  static const Rect jbZone = Rect.fromLTRB(230, 0, 970, 188);
  static const Offset bridgePoint = Offset(462, 196);

  // ---- towns: (position, name, Singlish sub-label) ----
  static const List<(Offset, String, String)> _towns = [
    (Offset(300, 330), 'Lim Chu Kang', 'So Far So Good'),
    (Offset(455, 260), 'Woodlands', 'Where Trees Win'),
    (Offset(470, 322), 'Sembawang', 'Ship? What Ship?'),
    (Offset(568, 270), 'Yishun', 'North & Slightly Up'),
    (Offset(705, 305), 'Punggol', 'Pond Goals'),
    (Offset(720, 372), 'Sengkang', 'Sengkang Can One'),
    (Offset(520, 388), 'Ang Mo Kio', 'Ang Mo Kiasi'),
    (Offset(640, 402), 'Hougang', 'Hougang Got Heart'),
    (Offset(838, 402), 'Pasir Ris', 'Pasir Nice'),
    (Offset(360, 428), 'Bukit Panjang', 'MRT Climb King'),
    (Offset(520, 452), 'Bishan', 'Bishan Got River'),
    (Offset(620, 462), 'Serangoon', 'Nasi Lemak Near Me'),
    (Offset(806, 462), 'Tampines', 'Everything Also Here'),
    (Offset(392, 486), 'Bukit Timah', 'Hill Wee'),
    (Offset(540, 522), 'Toa Payoh', 'Old But Gold'),
    (Offset(922, 470), 'Changi', 'Plane See You!'),
    (Offset(128, 486), 'Tuas', 'The End (almost)'),
    (Offset(198, 508), 'Pioneer', 'Pioneers Leh'),
    (Offset(252, 546), 'Boon Lay', 'Bo On Lah'),
    (Offset(322, 566), 'Jurong West', 'The West Best'),
    (Offset(360, 606), 'Jurong East', 'JE Tiao Eh'),
    (Offset(452, 566), 'Clementi', 'Clementi Can!'),
    (Offset(786, 542), 'Bedok', 'Bedok Liao'),
    (Offset(482, 614), 'Queenstown', 'The OG Queen'),
    (Offset(562, 592), 'Orchard', 'Shop Till Drop'),
    (Offset(742, 620), 'Expo', 'Big Events, Bigger Food'),
    (Offset(560, 662), 'City', 'Work Hard Nap Hard'),
    (Offset(642, 662), 'Marina Bay', 'Look At All The Buildings'),
    (Offset(500, 752), 'Sentosa', 'Vacation Mode On'),
  ];

  static const List<(Offset, String, String)> _tekongTowns = [
    (Offset(1060, 400), 'BMTC', 'Botak Man Training Center'),
    (Offset(1170, 348), 'SISPEC', 'Suffer In Silence + Confinement'),
    (Offset(1290, 392), 'SIT', 'Sweat, Insects, Tekan'),
  ];

  // ---- MRT-ish connector polylines ----
  static const List<List<Offset>> _roads = [
    [Offset(455, 260), Offset(470, 322), Offset(568, 270), Offset(705, 305), Offset(720, 372), Offset(838, 402), Offset(806, 462), Offset(922, 470)],
    [Offset(360, 428), Offset(520, 452), Offset(520, 388), Offset(620, 462), Offset(640, 402)],
    [Offset(520, 452), Offset(540, 522), Offset(562, 592), Offset(560, 662), Offset(642, 662)],
    [Offset(128, 486), Offset(198, 508), Offset(252, 546), Offset(322, 566), Offset(360, 606), Offset(452, 566), Offset(482, 614), Offset(560, 662)],
    [Offset(806, 462), Offset(786, 542), Offset(742, 620)],
    [Offset(392, 486), Offset(360, 428)],
    [Offset(392, 486), Offset(452, 566)],
    [Offset(300, 330), Offset(360, 428)],
  ];

  static const List<List<Offset>> _rivers = [
    [Offset(505, 430), Offset(524, 470), Offset(506, 510), Offset(526, 548)],
    [Offset(320, 560), Offset(300, 600), Offset(330, 636), Offset(312, 670)],
  ];

  static const List<Offset> _trees = [
    Offset(620, 300), Offset(660, 330), Offset(430, 360), Offset(760, 420),
    Offset(300, 470), Offset(470, 520), Offset(690, 560), Offset(560, 640),
    Offset(220, 470), Offset(830, 500), Offset(1120, 250), Offset(1270, 300),
    Offset(1100, 470), Offset(1260, 460),
  ];

  static const List<Offset> _waves = [
    Offset(120, 200), Offset(300, 160), Offset(1050, 620), Offset(1180, 660),
    Offset(980, 720), Offset(240, 720), Offset(120, 620), Offset(700, 760),
    Offset(880, 180), Offset(1000, 120),
  ];


  static ui.Picture? _scene;

  // ---- static scene ----------------------------------------------------------

  static Offset _mid(Offset a, Offset b) => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  static Path _smoothClosed(List<Offset> pts) {
    final path = Path();
    if (pts.length < 3) return path;
    final start = _mid(pts.last, pts.first);
    path.moveTo(start.dx, start.dy);
    for (var i = 0; i < pts.length; i++) {
      final cur = pts[i];
      final m = _mid(cur, pts[(i + 1) % pts.length]);
      path.quadraticBezierTo(cur.dx, cur.dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  static ui.Picture _buildScene() {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);

    // Waves + clouds in the sea (world space).
    for (final w in _waves) {
      _wave(c, w);
    }

    // Landmasses.
    final landPaint = Paint()..color = _land;
    final coastPaint = Paint()
      ..color = _coast
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final p in [island, tekong, sentosa, jb]) {
      c.drawPath(p, landPaint);
      c.drawPath(p, coastPaint);
    }

    // The Causeway to JB (perpetually jammed).
    _causeway(c);

    // Tekong training pond.
    c.drawOval(Rect.fromCenter(center: const Offset(1180, 250), width: 90, height: 44),
        Paint()..color = const Color(0xFF8CB0B8));

    // Rivers.
    final riverPaint = Paint()
      ..color = _river
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final r in _rivers) {
      c.drawPath(_poly(r), riverPaint);
    }

    // MRT-ish roads.
    final roadPaint = Paint()
      ..color = _road
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final line in _roads) {
      c.drawPath(_poly(line), roadPaint);
    }

    // Trees.
    for (final t in _trees) {
      _tree(c, t);
    }

    // Landmarks.
    _merlion(c, const Offset(110, 780));
    _bumboat(c, const Offset(1120, 745));

    // Tekong title.
    _bigLabel(c, const Offset(1120, 170), 'Tekong', 'Confirm book in');
    _bigLabel(c, const Offset(430, 46), 'JB', 'Jam Bridge');

    // Town labels.
    for (final (pos, name, sub) in _towns) {
      _townLabel(c, pos, name, sub);
    }
    for (final (pos, name, sub) in _tekongTowns) {
      _townLabel(c, pos, name, sub);
    }

    return rec.endRecording();
  }

  static Path _poly(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      p.lineTo(o.dx, o.dy);
    }
    return p;
  }

  static void _wave(Canvas c, Offset at) {
    final paint = Paint()
      ..color = _seaWave.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 2; i++) {
      final y = at.dy + i * 9;
      final path = Path()
        ..moveTo(at.dx, y)
        ..quadraticBezierTo(at.dx + 7, y - 5, at.dx + 14, y)
        ..quadraticBezierTo(at.dx + 21, y + 5, at.dx + 28, y);
      c.drawPath(path, paint);
    }
  }

  static void _causeway(Canvas c) {
    final road = Paint()
      ..color = const Color(0xFFCBB68C)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(460, 150), const Offset(460, 240), road);
    final lane = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    for (var y = 158.0; y < 236; y += 12) {
      c.drawLine(Offset(460, y), Offset(460, y + 6), lane);
    }
    // Cars queued in the jam.
    const cars = [Color(0xFFE2231A), Color(0xFF3D6FB4), Color(0xFFEFC94C), Color(0xFF37474F), Color(0xFFE2231A)];
    var y = 160.0;
    for (var i = 0; i < cars.length; i++) {
      final x = 460 + (i.isEven ? -4.5 : 4.5);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 4, y, 8, 12), const Radius.circular(2)),
          Paint()..color = cars[i]);
      y += 15;
    }
  }

  static void _tree(Canvas c, Offset at) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(at.dx - 3, at.dy, 6, 14), const Radius.circular(2)),
      Paint()..color = const Color(0xFF9A6B3F),
    );
    final leaf = Paint()..color = const Color(0xFF7CB342);
    c.drawCircle(at + const Offset(0, -8), 13, leaf);
    c.drawCircle(at + const Offset(-9, -2), 9, leaf);
    c.drawCircle(at + const Offset(9, -2), 9, leaf);
    c.drawCircle(at + const Offset(0, -8), 13, Paint()
      ..color = const Color(0xFF5E9A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  static void _merlion(Canvas c, Offset at) {
    // Rock.
    c.drawOval(Rect.fromCenter(center: at + const Offset(0, 34), width: 92, height: 30),
        Paint()..color = const Color(0xFFBFC6CB));
    // Body + head (obvious cartoon parody).
    final white = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = const Color(0xFFB9C0C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final body = Path()
      ..moveTo(at.dx - 16, at.dy + 30)
      ..quadraticBezierTo(at.dx - 24, at.dy - 4, at.dx - 6, at.dy - 20)
      ..quadraticBezierTo(at.dx + 6, at.dy - 30, at.dx + 20, at.dy - 20)
      ..quadraticBezierTo(at.dx + 14, at.dy - 6, at.dx + 18, at.dy + 8)
      ..quadraticBezierTo(at.dx + 20, at.dy + 24, at.dx + 10, at.dy + 30)
      ..close();
    c.drawPath(body, white);
    c.drawPath(body, outline);
    c.drawCircle(at + const Offset(4, -6), 3, Paint()..color = Colors.black87);
    // Water spout.
    final spout = Paint()
      ..color = _river
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawPath(
      Path()
        ..moveTo(at.dx + 16, at.dy - 16)
        ..quadraticBezierTo(at.dx + 60, at.dy - 40, at.dx + 74, at.dy + 20),
      spout,
    );
  }

  static void _bumboat(Canvas c, Offset at) {
    final hull = Path()
      ..moveTo(at.dx - 42, at.dy)
      ..lineTo(at.dx + 46, at.dy)
      ..lineTo(at.dx + 30, at.dy + 20)
      ..lineTo(at.dx - 30, at.dy + 20)
      ..close();
    c.drawPath(hull, Paint()..color = const Color(0xFFB63A34));
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(at.dx - 20, at.dy - 18, 40, 18), const Radius.circular(4)),
      Paint()..color = const Color(0xFFE9E2D0),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(at.dx - 4, at.dy - 30, 6, 14), const Radius.circular(2)),
      Paint()..color = const Color(0xFF5C1E70),
    );
    // Wake.
    final wake = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    c.drawLine(at + const Offset(-42, 12), at + const Offset(-72, 8), wake);
    c.drawLine(at + const Offset(-42, 18), at + const Offset(-66, 22), wake);
  }

  static TextPainter _tp(String s, double size, FontWeight w, Color color, String family, {double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontFamily: family, fontSize: size, fontWeight: w, color: color, height: 1.15),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    return tp;
  }

  static void _rrect(Canvas c, Rect r, Color fill, double radius, {Color? border}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
    c.drawRRect(rr, Paint()..color = fill);
    if (border != null) {
      c.drawRRect(rr, Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
  }

  static void _townLabel(Canvas c, Offset pos, String name, String sub) {
    c.drawCircle(pos, 7, Paint()..color = AppColors.purple);
    c.drawCircle(pos, 3, Paint()..color = Colors.white);

    final namePos = pos + const Offset(11, -11);
    final nameTp = _tp(name, 14, FontWeight.w800, const Color(0xFF1C1814), AppFonts.display);
    _rrect(c, Rect.fromLTWH(namePos.dx - 2, namePos.dy - 1, nameTp.width + 4, nameTp.height + 2),
        Colors.white.withValues(alpha: 0.7), 3);
    nameTp.paint(c, namePos);

    final subTp = _tp(sub, 11, FontWeight.w600, const Color(0xFF5A5248), AppFonts.body, maxWidth: 132);
    final subPos = Offset(namePos.dx, namePos.dy + nameTp.height + 3);
    _rrect(c, Rect.fromLTWH(subPos.dx - 5, subPos.dy - 3, subTp.width + 10, subTp.height + 6),
        Colors.white, 6, border: const Color(0x22000000));
    subTp.paint(c, subPos);
  }

  static void _bigLabel(Canvas c, Offset at, String title, String sub) {
    final t = _tp(title, 30, FontWeight.w900, AppColors.purple, AppFonts.display);
    t.paint(c, at);
    final s = _tp(sub, 15, FontWeight.w700, const Color(0xFF1C1814), AppFonts.display);
    s.paint(c, at + Offset(0, t.height + 2));
  }

  // ---- per-frame paint -------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _sea);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-camCenter.dx, -camCenter.dy);

    _scene ??= _buildScene();
    canvas.drawPicture(_scene!);

    final atSea = !island.contains(busPos) &&
        !tekong.contains(busPos) &&
        !sentosa.contains(busPos) &&
        !jb.contains(busPos);
    _drawBus(canvas, busPos, heading, atSea);
    canvas.restore();
  }

  void _drawBus(Canvas canvas, Offset pos, double heading, bool atSea) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (grabbed) {
      canvas.drawCircle(Offset.zero, 24, Paint()..color = AppColors.amber.withValues(alpha: 0.18));
      canvas.drawCircle(Offset.zero, 24, Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }
    canvas.rotate(heading);
    const w = 34.0, h = 18.0;
    if (atSea) _drawPropeller(canvas, w);
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(-w / 2, -h / 2, w, h), const Radius.circular(5));
    canvas.drawShadow(Path()..addRRect(rect), Colors.black, 3, false);
    canvas.drawRRect(rect, Paint()..color = AppColors.amber);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 6, -h / 2, 6, h), const Radius.circular(4)),
      Paint()..color = AppColors.red,
    );
    final win = Paint()..color = const Color(0xFF263238);
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 4 + i * 8.5, -h / 2 + 3.5, 6, 5.5), const Radius.circular(1.5)),
        win,
      );
    }
    canvas.restore();
  }

  void _drawPropeller(Canvas canvas, double busW) {
    final backX = -busW / 2;
    final foam = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 3; i++) {
      final fx = backX - 12 - i * 7.0;
      canvas.drawCircle(Offset(fx, -3.0 + i), 3.5 - i * 0.6, foam);
      canvas.drawCircle(Offset(fx - 3, 3.0 - i), 3.0 - i * 0.6, foam);
    }
    final steel = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final hub = Offset(backX - 9, 0);
    canvas.drawLine(Offset(backX, 0), hub, steel);
    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.drawCircle(Offset.zero, 9, Paint()..color = const Color(0x33455A64));
    canvas.rotate(propellerSpin);
    final blade = Paint()..color = const Color(0xFF455A64);
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.rotate(i * 2 * pi / 3);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(5, -7, 0, -12)
        ..quadraticBezierTo(-5, -7, 0, 0)
        ..close();
      canvas.drawPath(path, blade);
      canvas.restore();
    }
    canvas.restore();
    canvas.drawCircle(hub, 2.6, Paint()..color = const Color(0xFF263238));
  }

  @override
  bool shouldRepaint(covariant SgMapPainter old) =>
      old.busPos != busPos ||
      old.heading != heading ||
      old.scale != scale ||
      old.camCenter != camCenter ||
      old.propellerSpin != propellerSpin ||
      old.grabbed != grabbed;
}
