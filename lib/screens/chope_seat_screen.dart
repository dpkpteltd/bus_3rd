import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

enum SeatStatus { free, choped, taken }

/// The "chope a seat" gag: tap an empty seat to reserve it with a tissue packet.
/// Random "aunties" chope seats over time to create comedic urgency.
class ChopeSeatScreen extends StatefulWidget {
  const ChopeSeatScreen({super.key});

  @override
  State<ChopeSeatScreen> createState() => _ChopeSeatScreenState();
}

class _ChopeSeatScreenState extends State<ChopeSeatScreen> {
  static const _rows = 8;
  static const _cols = 4;

  final Random _rng = Random();
  late List<SeatStatus> _seats;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seats = List.generate(_rows * _cols,
        (i) => _rng.nextInt(4) == 0 ? SeatStatus.taken : SeatStatus.free);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _autoChope());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _chopedByMe => _seats.where((s) => s == SeatStatus.choped).length;

  void _autoChope() {
    final free = <int>[];
    for (var i = 0; i < _seats.length; i++) {
      if (_seats[i] == SeatStatus.free) free.add(i);
    }
    if (free.isEmpty) return;
    setState(() => _seats[free[_rng.nextInt(free.length)]] = SeatStatus.taken);
  }

  void _onTap(int index) {
    String message;
    switch (_seats[index]) {
      case SeatStatus.free:
        setState(() => _seats[index] = SeatStatus.choped);
        message = 'Choped! Tissue packet deployed 🧻';
      case SeatStatus.choped:
        setState(() => _seats[index] = SeatStatus.free);
        message = 'Tissue packet retrieved. Seat un-choped.';
      case SeatStatus.taken:
        message = const [
          'Someone already choped this leh 😤',
          'Taken! The tissue got there first.',
          'No use. Aunty was faster.',
        ][_rng.nextInt(3)];
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 1400)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(locationLabel: 'Choping seat on', locationValue: 'Bus 88 → Toa Payoh'),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chope a Seat', style: T.display(22, weight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('Tap an empty seat. You\'ve choped $_chopedByMe.',
                        style: T.body(12.5, color: AppColors.muted)),
                  ],
                ),
              ),
              const Text('🧻', style: TextStyle(fontSize: 30)),
            ],
          ),
        ),
        Expanded(child: _seatGrid()),
        _legend(),
      ],
    );
  }

  Widget _seatGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: GridView.builder(
        itemCount: _rows * _cols,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final col = index % _cols;
          return Padding(
            padding: EdgeInsets.only(right: col == 1 ? 14 : 0, left: col == 2 ? 14 : 0),
            child: _seat(index),
          );
        },
      ),
    );
  }

  Widget _seat(int index) {
    late final Color color;
    late final IconData icon;
    switch (_seats[index]) {
      case SeatStatus.free:
        color = AppColors.green;
        icon = Icons.event_seat_outlined;
      case SeatStatus.choped:
        color = AppColors.amber;
        icon = Icons.cleaning_services;
      case SeatStatus.taken:
        color = AppColors.red;
        icon = Icons.person;
    }
    return Material(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTap(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  Widget _legend() {
    Widget item(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.2),
                border: Border.all(color: c),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: T.body(12, color: AppColors.inkSoft)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          item(AppColors.green, 'Empty'),
          item(AppColors.amber, 'Choped (you)'),
          item(AppColors.red, 'Taken'),
        ],
      ),
    );
  }
}
