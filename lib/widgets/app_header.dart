import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'logo_badge.dart';

/// The red gradient app chrome: logo, an optional right-side action (the MRT
/// toggle on Home), and the "You are stuck at" location card.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.trailing,
    this.locationLabel = 'You are stuck at',
    this.locationValue = 'Bishan Int · 53009',
  });

  final Widget? trailing;
  final String locationLabel;
  final String locationValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.redHeader,
        ),
        boxShadow: [
          BoxShadow(color: Color(0x47AA140C), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LogoBadge(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.amber, blurRadius: 8)],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationLabel.toUpperCase(),
                        style: T.body(10.5,
                                color: Colors.white.withValues(alpha: 0.7),
                                weight: FontWeight.w600)
                            .copyWith(letterSpacing: 0.6),
                      ),
                      Text(locationValue,
                          style: T.display(15, color: Colors.white, weight: FontWeight.w800, spacing: 0.1)),
                    ],
                  ),
                ),
                Text('change ›',
                    style: T.mono(11, color: Colors.white.withValues(alpha: 0.6), weight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The MRT-mode pill switch shown on the right of the Home header.
class MrtToggle extends StatelessWidget {
  const MrtToggle({super.key, required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 6, 9, 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MRT MODE',
                style: T.display(10.5, color: Colors.white, weight: FontWeight.w800, spacing: 0.6)),
            const SizedBox(width: 9),
            Container(
              width: 42,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.purple : Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2.5),
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
