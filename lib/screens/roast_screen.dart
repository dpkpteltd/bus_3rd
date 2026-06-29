import 'package:flutter/material.dart';

import '../services/ai/ai_models.dart';
import '../services/ai/ai_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

/// "Roast my commute" — the user names a destination and gets a personalized
/// absurd forecast plus a prank notification, in the app's voice.
class RoastScreen extends StatefulWidget {
  const RoastScreen({super.key});

  @override
  State<RoastScreen> createState() => _RoastScreenState();
}

class _RoastScreenState extends State<RoastScreen> {
  final TextEditingController _input = TextEditingController();
  AiRoast? _result;
  bool _loading = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _roast() async {
    final dest = _input.text.trim();
    if (dest.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final r = await AiService.instance.roast(dest);
    if (!mounted) return;
    setState(() {
      _result = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: Text('Roast my commute 🔥', style: T.display(18, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Where you trying to go?', style: T.display(20, weight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('We will tell you how badly it goes.', style: T.body(13, color: AppColors.muted)),
          const SizedBox(height: 14),
          TextField(
            controller: _input,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _roast(),
            decoration: InputDecoration(
              hintText: 'e.g. work, the airport, my ex’s house',
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _roast,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Roast me', style: T.display(15, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 22),
            _resultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _resultCard(AiRoast r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(r.minutesLate, style: T.display(52, color: AppColors.red, weight: FontWeight.w900).copyWith(height: 0.85)),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('min late', style: T.body(15, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.tagRedBg, borderRadius: BorderRadius.circular(6)),
            child: Text(r.verdict, style: T.body(12, color: AppColors.tagRedFg, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Text(r.note, style: T.body(14, color: AppColors.inkSoft, height: 1.5)),
          const SizedBox(height: 6),
          Text('Confidence: ${r.confidence}', style: T.body(12, color: AppColors.muted)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => NotificationService.instance.showCustomPrank('Bus 3rd', r.prank),
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: Text('Send myself this prank', style: T.body(13, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
