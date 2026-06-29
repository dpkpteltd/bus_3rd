import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/fake_data.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_wheel.dart';

/// The splash / "login" loading screen. Pretends to load forever; the user
/// taps "Aiya, just let me in" to enter the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onEnter});

  final VoidCallback onEnter;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Random _rng = Random();
  Timer? _msgTimer;
  Timer? _progTimer;
  int _msgIdx = 0;
  double _progress = 8;
  bool _cursorOn = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _msgTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() => _msgIdx = (_msgIdx + 1) % FakeData.loadingMsgs.length);
    });
    _progTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      setState(() {
        var p = _progress + _rng.nextDouble() * 11;
        if (p > 94) p = 89 + _rng.nextDouble() * 5;
        if (_rng.nextDouble() < 0.18) p = max(34, p - 17);
        _progress = min(p, 96);
      });
    });
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      setState(() => _cursorOn = !_cursorOn);
    });
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _progTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _progress.round();
    final note = pct > 88
        ? 'almost there (it is not)'
        : pct < 40
            ? 'going backwards now'
            : 'stand by lah';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.85),
            radius: 1.1,
            colors: AppColors.splashGradient,
            stops: [0, 0.52, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const LoadingWheel(size: 130),
                const SizedBox(height: 36),
                _logoChip(),
                const SizedBox(height: 14),
                Text(
                  'Always running late. Never just running.',
                  textAlign: TextAlign.center,
                  style: T.body(13, color: Colors.white.withValues(alpha: 0.62), weight: FontWeight.w600),
                ),
                const SizedBox(height: 34),
                _progressBlock(pct, note),
                const Spacer(),
                _enterButton(),
                const SizedBox(height: 15),
                Text('v3.0 · still loading since 2019',
                    style: T.mono(10.5, color: Colors.white.withValues(alpha: 0.3), weight: FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.darkChip,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF303030)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('BUS', style: T.mono(23, color: AppColors.amber, weight: FontWeight.w700).copyWith(letterSpacing: 1)),
          const SizedBox(width: 9),
          Text('3rd', style: T.display(25, color: AppColors.red, weight: FontWeight.w900, spacing: -0.5)),
        ],
      ),
    );
  }

  Widget _progressBlock(int pct, String note) {
    return SizedBox(
      width: 298,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: Text(
              '> ${FakeData.loadingMsgs[_msgIdx]}${_cursorOn ? '▋' : ' '}',
              style: T.mono(12.5, color: AppColors.amber, weight: FontWeight.w400).copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 9,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (pct / 100).clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.red, AppColors.amber]),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$pct%', style: T.mono(10.5, color: Colors.white.withValues(alpha: 0.42), weight: FontWeight.w400)),
              Text(note, style: T.mono(10.5, color: Colors.white.withValues(alpha: 0.42), weight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _enterButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: widget.onEnter,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text('Aiya, just let me in  →',
            style: T.display(15, color: Colors.white, weight: FontWeight.w800, spacing: 0.2)),
      ),
    );
  }
}
