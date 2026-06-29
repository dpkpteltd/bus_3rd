import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_badge.dart';

/// The parody disclaimer + privacy statement + prank controls. Important for
/// store review: it makes clear this is an entertainment app, not a real
/// transit service.
const String kParodyDisclaimer =
    'Bus 3rd is a parody / comedy app for entertainment only. All bus timings, '
    'routes, stops, seats and notifications are completely fictional and '
    'intentionally inaccurate. Do NOT use this app to catch a real bus. '
    'Bus 3rd is not affiliated with, endorsed by, or connected to any real '
    'transit operator or government agency.';

const String kPrivacyStatement =
    'Bus 3rd collects no personal data. There are no accounts, no analytics, no '
    'ads, and no location tracking. Your settings stay on your device.';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: Text('About', style: T.display(18, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const LogoBadge(busSize: 22, thirdSize: 24, thirdColor: AppColors.red),
                const SizedBox(height: 12),
                Text('Bus 3rd Transit Co. · v1.0.0', style: T.mono(11, color: AppColors.muted, weight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text('Late, but emotionally prepared.',
                    style: T.body(13, color: AppColors.inkSoft, weight: FontWeight.w600, style: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section('This is a joke 🤡', kParodyDisclaimer),
          const SizedBox(height: 14),
          _section('Privacy', kPrivacyStatement),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) => _card(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.red,
                    title: Text('Prank notifications', style: T.body(14.5, weight: FontWeight.w700)),
                    subtitle: Text('Silly fake alerts (local only)', style: T.body(12, color: AppColors.muted)),
                    value: appState.pranksEnabled,
                    onChanged: (v) async {
                      appState.setPranksEnabled(v);
                      if (v) await NotificationService.instance.requestPermission();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt, color: AppColors.amberDark),
                    title: Text('Send a prank now', style: T.body(14.5, weight: FontWeight.w700)),
                    enabled: appState.pranksEnabled,
                    onTap: () async {
                      final granted = await NotificationService.instance.requestPermission();
                      await NotificationService.instance.showPrankNow();
                      if (context.mounted && !granted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Allow notifications to get pranked 😈'),
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: T.display(16, weight: FontWeight.w800, spacing: 0)),
            const SizedBox(height: 8),
            Text(body, style: T.body(13.5, color: AppColors.inkSoft, height: 1.5)),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: child,
      );
}
