import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "Give Up" flow — the app's tongue-in-cheek logout. Confirm that you have
/// given up, then receive your certificate of inner peace.
class GiveUpScreen extends StatefulWidget {
  const GiveUpScreen({super.key, required this.onGoHome});

  /// Returns the user to the Home tab (and resets this flow).
  final VoidCallback onGoHome;

  @override
  State<GiveUpScreen> createState() => _GiveUpScreenState();
}

class _GiveUpScreenState extends State<GiveUpScreen>
    with SingleTickerProviderStateMixin {
  bool _done = false;
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _floating(String emoji, double size) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -14 * _float.value),
        child: Transform.rotate(angle: (-0.05 + 0.1 * _float.value), child: child),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: _done ? _congrats() : _confirm());
  }

  // ---- confirm -------------------------------------------------------------

  Widget _confirm() {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
      child: SafeArea(
        child: Column(
          children: [
            Text('STEP 1 OF 1 · THE ONLY HONEST STEP',
                style: T.mono(11, color: AppColors.faint, weight: FontWeight.w400).copyWith(letterSpacing: 1)),
            const Spacer(),
            _floating('🏳️', 64),
            const SizedBox(height: 8),
            Text('Ready to give up?',
                textAlign: TextAlign.center,
                style: T.display(30, weight: FontWeight.w900).copyWith(height: 1.08)),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text('The bus is not coming. You know this. We know this. Let go.',
                  textAlign: TextAlign.center, style: T.body(15, color: AppColors.inkSoft, height: 1.55)),
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _done = true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('Tap to confirm you have given up',
                      textAlign: TextAlign.center,
                      style: T.display(16, color: Colors.white, weight: FontWeight.w900, spacing: 0.2)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onGoHome,
              child: Text('No lah, I keep suffering',
                  style: T.body(13.5, color: AppColors.muted2, weight: FontWeight.w600)
                      .copyWith(decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  // ---- congrats ------------------------------------------------------------

  Widget _congrats() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.65),
          radius: 1.1,
          colors: AppColors.peaceGradient,
          stops: [0, 0.55, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(30, 56, 30, 40),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _floating('🕊️', 70),
            const SizedBox(height: 10),
            Text('You chose peace',
                textAlign: TextAlign.center,
                style: T.display(32, color: Colors.white, weight: FontWeight.w900).copyWith(height: 1.05)),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'You have been removed from the bus queue and the rat race. Congratulations.',
                textAlign: TextAlign.center,
                style: T.body(15, color: Colors.white.withValues(alpha: 0.72), height: 1.55),
              ),
            ),
            const SizedBox(height: 30),
            _statsCard(),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onGoHome,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.all(17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Walk home (47 min)', style: T.display(15, weight: FontWeight.w800, spacing: 0)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('no buses were harmed. none showed up either.',
                textAlign: TextAlign.center,
                style: T.mono(10.5, color: Colors.white.withValues(alpha: 0.34), weight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    Widget row(String label, String value, {Color valueColor = AppColors.amber, bool border = true, double valueSize = 16}) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: border
              ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.09)))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: T.body(13.5, color: Colors.white.withValues(alpha: 0.7)))),
            Text(value, style: T.display(valueSize, color: valueColor, weight: FontWeight.w800, spacing: 0.3)),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            row('Buses missed today', '4'),
            row('Minutes you will never get back', '∞'),
            row('Inner peace', 'UNLOCKED', valueColor: AppColors.greenLight, border: false, valueSize: 13),
          ],
        ),
      ),
    );
  }
}
