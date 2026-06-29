import 'dart:async';

import 'package:flutter/material.dart';

import '../data/fake_data.dart';
import '../models/bus_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _breakdown = false;
  int _lateIdx = 0;
  int _feedCount = 3;
  Timer? _feedTimer;

  @override
  void dispose() {
    _feedTimer?.cancel();
    super.dispose();
  }

  void _toggleBreakdown() {
    setState(() {
      _breakdown = !_breakdown;
      _feedCount = 3;
    });
    _feedTimer?.cancel();
    if (_breakdown) {
      _feedTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
        if (_feedCount >= FakeData.feed.length) {
          _feedTimer?.cancel();
          return;
        }
        setState(() => _feedCount++);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          trailing: MrtToggle(value: _breakdown, onTap: _toggleBreakdown),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (_breakdown) ...[
                _disruptionCard(),
                _feedCard(),
              ] else
                _predictorCard(),
              _sectionRow('Next arrivals', 'allegedly'),
              for (var i = 0; i < FakeData.buses.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _busCard(FakeData.buses[i], i),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 9),
                child: Text('What aunty & uncle say',
                    style: T.display(17, weight: FontWeight.w900, spacing: 0)),
              ),
              for (final r in FakeData.reviews)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _reviewCard(r),
                ),
              _aboutFooter(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aboutFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.goldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.goldText),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('It\'s a joke — please read',
                        style: T.body(13.5, color: AppColors.goldText, weight: FontWeight.w700)),
                    Text('Parody app · about & disclaimer',
                        style: T.body(11.5, color: AppColors.goldText2)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.goldText2),
            ],
          ),
        ),
      ),
    );
  }

  // ---- predictor -----------------------------------------------------------

  Widget _predictorCard() {
    final late = FakeData.latePredictions[_lateIdx % FakeData.latePredictions.length];
    return _whiteCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW LATE WILL YOU BE TODAY?',
              style: T.display(11.5, color: AppColors.muted2, weight: FontWeight.w800, spacing: 0.5)),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(late.mins, style: T.display(58, color: AppColors.red, weight: FontWeight.w900, spacing: -1).copyWith(height: 0.82)),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('min late', style: T.body(16, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          RichText(
            text: TextSpan(
              style: T.body(12.5, color: AppColors.inkSoft),
              children: [
                const TextSpan(text: 'Confidence: '),
                TextSpan(text: late.confidence, style: T.body(12.5, color: AppColors.ink, weight: FontWeight.w800)),
                TextSpan(text: ' · ${late.note}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _lateIdx++),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.cream,
                foregroundColor: AppColors.ink,
                side: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Recalculate ↻', style: T.display(13, weight: FontWeight.w700, spacing: 0)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- breakdown -----------------------------------------------------------

  Widget _disruptionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.purpleCard,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.purpleDark.withValues(alpha: 0.38), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠', style: TextStyle(fontSize: 19, color: Colors.white)),
              const SizedBox(width: 9),
              Text('SERVICE DISRUPTION',
                  style: T.display(15, color: Colors.white, weight: FontWeight.w900, spacing: 0.3)),
            ],
          ),
          const SizedBox(height: 9),
          Text('We are sorry for any inconvenience caused.',
              style: T.body(13.5, color: Colors.white.withValues(alpha: 0.95), weight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: 3),
          Text('(We are not.)',
              style: T.body(12, color: Colors.white.withValues(alpha: 0.6), style: FontStyle.italic)),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Text('🚌', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: T.body(12.5, color: Colors.white, weight: FontWeight.w600, height: 1.4),
                      children: [
                        const TextSpan(text: 'Free shuttle bus available at affected stops '),
                        TextSpan(text: '(also late)', style: T.body(12.5, color: Colors.white.withValues(alpha: 0.7), weight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedCard() {
    final items = FakeData.feed.take(_feedCount).toList().reversed.toList();
    return _whiteCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LIVE UPDATES', style: T.display(12, color: AppColors.purple, weight: FontWeight.w800, spacing: 0.5)),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('LIVE', style: T.mono(10, color: AppColors.muted2, weight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),
          for (final f in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 42, child: Text(f.time, style: T.mono(11, color: AppColors.purple, weight: FontWeight.w700))),
                  const SizedBox(width: 11),
                  Expanded(child: Text(f.message, style: T.body(13, color: const Color(0xFF2A2A2A), height: 1.45))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---- bus + review cards --------------------------------------------------

  Widget _busCard(BusItem b, int i) {
    final tagBg = _breakdown ? AppColors.tagPurpleBg : AppColors.tagRedBg;
    final tagFg = _breakdown ? AppColors.tagPurpleFg : AppColors.tagRedFg;
    final verdict = _breakdown ? 'SUSPENDED' : b.verdict;
    final sub = _breakdown ? FakeData.susSubs[i % FakeData.susSubs.length] : b.sub;
    final times = _breakdown ? '—' : b.times;
    final timeColor = _breakdown ? AppColors.faint : b.timeColor;

    return _whiteCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: b.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Text(b.plate, style: T.display(18, color: Colors.white, weight: FontWeight.w900, spacing: -0.3)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.dest, style: T.body(14.5, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(verdict, style: T.body(11.5, color: tagFg, weight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Text(sub, style: T.body(11.5, color: AppColors.muted, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(times, style: T.mono(13, color: timeColor, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('min · min · min',
                  style: T.body(9.5, color: AppColors.faint).copyWith(letterSpacing: 0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Review r) {
    return _whiteCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: r.avatarBg, shape: BoxShape.circle),
                child: Text(r.initials, style: T.display(14, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: T.body(13.5, weight: FontWeight.w800)),
                    Text('${'★' * r.stars}${'☆' * (5 - r.stars)}',
                        style: const TextStyle(color: AppColors.amber, fontSize: 12, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('“${r.quote}”', style: T.body(13.5, color: const Color(0xFF3A342E), height: 1.5)),
        ],
      ),
    );
  }

  // ---- helpers -------------------------------------------------------------

  Widget _sectionRow(String title, String aside) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: T.display(17, weight: FontWeight.w900, spacing: 0)),
          Text(aside, style: T.body(12, color: AppColors.muted2, style: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? margin, required EdgeInsets padding}) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}
