import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/ai/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'roast_screen.dart';
import 'uncle_chat_screen.dart';

/// The AI tab: a hub for the live (MiniMax-powered) comedy features, with the
/// online/offline toggle right where you'd look for it.
class AiHubScreen extends StatelessWidget {
  const AiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    return Column(
      children: [
        const AppHeader(locationLabel: 'AI mode', locationValue: 'Fresh nonsense, on demand'),
        Expanded(
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              final online = appState.aiOnline && AiService.instance.isConfigured;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _statusCard(appState, online),
                  const SizedBox(height: 16),
                  _featureTile(
                    context,
                    emoji: '🧓',
                    title: 'Ask the Uncle',
                    subtitle: 'Chat with the gruff, unbothered bus uncle.',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UncleChatScreen())),
                  ),
                  const SizedBox(height: 12),
                  _featureTile(
                    context,
                    emoji: '🔥',
                    title: 'Roast my commute',
                    subtitle: 'Name a destination, get a brutal forecast.',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RoastScreen())),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statusCard(AppState appState, bool online) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: online ? AppColors.green : AppColors.muted2,
              shape: BoxShape.circle,
              boxShadow: online ? const [BoxShadow(color: AppColors.green, blurRadius: 8)] : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(online ? 'Online jokes' : 'Offline pretend mode',
                    style: T.body(14.5, weight: FontWeight.w800)),
                Text(
                  online
                      ? 'Fresh AI-generated nonsense'
                      : appState.aiConfigured
                          ? 'Using on-device canned jokes'
                          : 'No backend in this build',
                  style: T.body(11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (appState.aiConfigured)
            Switch(
              activeColor: AppColors.red,
              value: appState.aiOnline,
              onChanged: appState.setAiOnline,
            ),
        ],
      ),
    );
  }

  Widget _featureTile(BuildContext context,
      {required String emoji, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: T.display(16.5, weight: FontWeight.w900, spacing: 0)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: T.body(12.5, color: AppColors.muted, height: 1.35)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted2),
          ],
        ),
      ),
    );
  }
}
