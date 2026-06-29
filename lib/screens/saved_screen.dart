import 'package:flutter/material.dart';

import '../data/fake_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                child: Text('Saved Stops', style: T.display(22, weight: FontWeight.w900)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Text('You saved these hoping it would help. It did not.',
                    style: T.body(13, color: AppColors.muted, style: FontStyle.italic, height: 1.5)),
              ),
              for (final s in FakeData.saved)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _savedCard(s.plate, s.color, s.dest, s.note),
                ),
              Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldBorder, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Text('Alerts sent: 0', style: T.body(13.5, color: AppColors.goldText, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('We never notify you. We respect your peace.',
                        textAlign: TextAlign.center,
                        style: T.body(11.5, color: AppColors.goldText2, height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _savedCard(String plate, Color color, String dest, String note) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.045)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 9, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
            child: Text(plate, style: T.display(15, color: Colors.white, weight: FontWeight.w900, spacing: 0)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest, style: T.body(14, weight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(note, style: T.body(11.5, color: AppColors.muted)),
              ],
            ),
          ),
          // A permanently-on (and useless) alert toggle.
          Container(
            width: 46,
            height: 27,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 21,
                height: 21,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
