import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/fake_data.dart';
import '../services/ai/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/map_painter.dart';

/// The "live map" gag: a stylised Singapore island the bus wanders across
/// aimlessly. Tap the GPS button to lock the camera onto the bus; pinch or use
/// the +/- buttons to zoom. No real map data, API keys, or location.
class FakeMapScreen extends StatefulWidget {
  const FakeMapScreen({super.key});

  @override
  State<FakeMapScreen> createState() => _FakeMapScreenState();
}

class _FakeMapScreenState extends State<FakeMapScreen>
    with SingleTickerProviderStateMixin {
  final Random _rng = Random();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  // Bus state (world coordinates).
  Offset _busPos = const Offset(540, 450);
  Offset _busVel = Offset.zero;
  Offset _target = const Offset(540, 450);
  double _heading = 0;
  double _propellerSpin = 0; // spins while the bus is boating through the sea
  static const double _speed = 78; // world units / second

  // Camera.
  double _zoom = 1.0; // multiplier over the "fit whole island" scale
  double _fitScale = 0.4; // set each build from the viewport size
  Offset _camCenter = SgMapPainter.islandBounds.center;
  bool _follow = false;
  double _zoomAtGestureStart = 1.0;
  Size _viewport = Size.zero;

  // Dragging the bus.
  bool _dragging = false;
  Offset _grabOffset = Offset.zero;

  // Caption bubble.
  Timer? _captionTimer;
  final List<String> _pool = [...FakeData.mapGags];
  int _ci = 0;
  late String _caption = _pool[0];

  double get _scale => _fitScale * _zoom;

  @override
  void initState() {
    super.initState();
    _pickTarget();
    _ticker = createTicker(_onTick)..start();
    _seedFreshCaption();
    _captionTimer = Timer.periodic(const Duration(seconds: 4), (_) => _rotateCaption());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _captionTimer?.cancel();
    super.dispose();
  }

  // ---- bus simulation --------------------------------------------------------

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    // While the user is dragging the bus, it's finger-controlled — pause the
    // auto-wander and the follow camera.
    if (!_dragging) {
      _stepBus(dt);
      if (_follow) {
        _camCenter = Offset.lerp(_camCenter, _busPos, (dt * 3).clamp(0.0, 1.0))!;
      }
    }
    _propellerSpin += dt * 22; // fast cartoon spin
    setState(() {});
  }

  void _stepBus(double dt) {
    final to = _target - _busPos;
    final dist = to.distance;
    if (dist < 22) _pickTarget();
    final desired = dist == 0 ? Offset.zero : (to / dist) * _speed;
    _busVel = Offset.lerp(_busVel, desired, (dt * 1.2).clamp(0.0, 1.0))!;
    _busPos += _busVel * dt;
    if (_busVel.distance > 2) _heading = atan2(_busVel.dy, _busVel.dx);
  }

  void _pickTarget() {
    if (_rng.nextInt(7) == 0) {
      // Occasionally wander off into the sea, for comedy.
      _target = Offset(_rng.nextDouble() * SgMapPainter.world.width,
          _rng.nextDouble() * SgMapPainter.world.height);
    } else {
      // Somewhere on/around the main island.
      _target = Offset(170 + _rng.nextDouble() * 720, 270 + _rng.nextDouble() * 360);
    }
  }

  // ---- camera ----------------------------------------------------------------

  Offset get _viewCenter => Offset(_viewport.width / 2, _viewport.height / 2);
  Offset _worldToScreen(Offset w) => _viewCenter + (w - _camCenter) * _scale;
  Offset _screenToWorld(Offset l) => _camCenter + (l - _viewCenter) / _scale;

  Offset _clampCam(Offset c) => Offset(
        c.dx.clamp(0.0, SgMapPainter.world.width),
        c.dy.clamp(0.0, SgMapPainter.world.height),
      );

  // ---- dragging the bus ------------------------------------------------------

  void _onLongPressStart(LongPressStartDetails d) {
    // Only grab if the press lands on (or near) the bus.
    if ((_worldToScreen(_busPos) - d.localPosition).distance > 44) return;
    setState(() {
      _dragging = true;
      _follow = false;
      _busVel = Offset.zero;
      _grabOffset = _busPos - _screenToWorld(d.localPosition);
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (!_dragging) return;
    setState(() {
      final w = _screenToWorld(d.localPosition) + _grabOffset;
      final delta = w - _busPos;
      if (delta.distance > 0.5) _heading = atan2(delta.dy, delta.dx);
      _busPos = w;
    });
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    if (!_dragging) return;
    setState(() {
      _dragging = false;
      _busVel = Offset.zero;
      _pickTarget(); // resume wandering from wherever it was dropped
    });
  }

  void _onScaleStart(ScaleStartDetails d) => _zoomAtGestureStart = _zoom;

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      if (d.scale != 1.0) {
        _zoom = (_zoomAtGestureStart * d.scale).clamp(0.9, 5.0);
      }
      if (d.focalPointDelta != Offset.zero) {
        _follow = false; // manual pan takes over from lock-on
        _camCenter = _clampCam(_camCenter - d.focalPointDelta / _scale);
      }
    });
  }

  void _nudgeZoom(double factor) => setState(() => _zoom = (_zoom * factor).clamp(0.9, 5.0));

  void _toggleFollow() {
    setState(() => _follow = !_follow);
    if (_follow) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Locked on 🎯 (it\'s still lost though)'),
          duration: Duration(milliseconds: 1400),
        ));
    }
  }

  // ---- captions --------------------------------------------------------------

  void _rotateCaption() {
    if (!mounted) return;
    setState(() => _caption = _pool[++_ci % _pool.length]);
  }

  Future<void> _seedFreshCaption() async {
    final gag = await AiService.instance.mapGag();
    if (!mounted) return;
    setState(() {
      _pool.insert(0, gag);
      _caption = gag;
    });
  }

  // ---- ui --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(locationLabel: 'Tracking', locationValue: 'Bus 88 (allegedly)'),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final vp = constraints.biggest;
              _viewport = vp;
              // Fit to the island's bounds (with a small margin) so it fills the
              // screen rather than the whole sea-padded world.
              _fitScale = 0.98 *
                  min(vp.width / SgMapPainter.islandBounds.width,
                      vp.height / SgMapPainter.islandBounds.height);
              return GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onLongPressStart: _onLongPressStart,
                onLongPressMoveUpdate: _onLongPressMoveUpdate,
                onLongPressEnd: _onLongPressEnd,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SgMapPainter(
                          busPos: _busPos,
                          heading: _heading,
                          scale: _scale,
                          camCenter: _camCenter,
                          propellerSpin: _propellerSpin,
                          grabbed: _dragging,
                        ),
                      ),
                    ),
                    Positioned(left: 16, right: 16, top: 16, child: _captionBubble()),
                    Positioned(right: 16, bottom: 16, child: _controls()),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _controls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _roundBtn(Icons.add, 'Zoom in', () => _nudgeZoom(1.35)),
        const SizedBox(height: 8),
        _roundBtn(Icons.remove, 'Zoom out', () => _nudgeZoom(1 / 1.35)),
        const SizedBox(height: 14),
        _roundBtn(
          _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
          _follow ? 'Unlock' : 'Lock on bus',
          _toggleFollow,
          active: _follow,
          big: true,
        ),
      ],
    );
  }

  Widget _roundBtn(IconData icon, String tip, VoidCallback onTap,
      {bool active = false, bool big = false}) {
    final size = big ? 56.0 : 44.0;
    return Tooltip(
      message: tip,
      child: Material(
        color: active ? AppColors.red : Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon,
                color: active ? Colors.white : AppColors.ink, size: big ? 26 : 22),
          ),
        ),
      ),
    );
  }

  Widget _captionBubble() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_caption),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bus, color: AppColors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(_caption, style: T.body(13, color: Colors.white, weight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
