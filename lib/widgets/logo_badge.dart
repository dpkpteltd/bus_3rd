import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "BUS 3rd" lockup on a dark chip, used on the splash and app header.
class LogoBadge extends StatelessWidget {
  const LogoBadge({
    super.key,
    this.busSize = 15,
    this.thirdSize = 16,
    this.thirdColor = Colors.white,
  });

  final double busSize;
  final double thirdSize;
  final Color thirdColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('BUS',
              style: T.mono(busSize, color: AppColors.amber, weight: FontWeight.w700)
                  .copyWith(letterSpacing: 0.5)),
          const SizedBox(width: 6),
          Text('3rd',
              style: T.display(thirdSize, color: thirdColor, weight: FontWeight.w900, spacing: -0.4)),
        ],
      ),
    );
  }
}
