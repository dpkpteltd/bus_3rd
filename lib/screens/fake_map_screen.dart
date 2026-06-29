import 'dart:async';

import 'package:flutter/material.dart';

import '../data/fake_data.dart';
import '../services/ai/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/map_painter.dart';

/// The "live map" gag: a hand-painted map (no Google Maps, no API key, no
/// location) with a bus that wanders into the sea and drives in circles.
class FakeMapScreen extends StatefulWidget {
  const FakeMapScreen({super.key});

  @override
  State<FakeMapScreen> createState() => _FakeMapScreenState();
}

class _FakeMapScreenState extends State<FakeMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))
        ..repeat();
  Timer? _captionTimer;
  String _caption = FakeData.randomMapGag();

  @override
  void initState() {
    super.initState();
    _refreshCaption();
    _captionTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refreshCaption());
  }

  Future<void> _refreshCaption() async {
    final gag = await AiService.instance.mapGag();
    if (mounted) setState(() => _caption = gag);
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(locationLabel: 'Tracking', locationValue: 'Bus 88 (allegedly)'),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: FakeMapPainter(t: _controller.value, isDark: false),
                  ),
                ),
              ),
              Positioned(left: 16, right: 16, top: 16, child: _captionBubble()),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Cannot find bus 🤷 (it found the sea)'),
                        duration: Duration(milliseconds: 1400),
                      ));
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      ],
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
