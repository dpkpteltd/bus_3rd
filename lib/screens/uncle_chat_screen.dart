import 'package:flutter/material.dart';

import '../services/ai/ai_models.dart';
import '../services/ai/ai_service.dart';
import '../theme/app_theme.dart';

/// "Ask the Uncle" — a comedic chat with the gruff, unbothered bus uncle.
/// Online mode talks to the real model; offline it improvises canned snark.
class UncleChatScreen extends StatefulWidget {
  const UncleChatScreen({super.key});

  @override
  State<UncleChatScreen> createState() => _UncleChatScreenState();
}

class _UncleChatScreenState extends State<UncleChatScreen> {
  final List<UncleTurn> _turns = [
    const UncleTurn(fromUser: false, text: 'Hah. You waiting for bus also? Sit lah. Talk to me.'),
  ];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _thinking = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _thinking) return;
    setState(() {
      _turns.add(UncleTurn(fromUser: true, text: text));
      _thinking = true;
      _input.clear();
    });
    _scrollToEnd();

    final reply = await AiService.instance.uncleReply(_turns);
    if (!mounted) return;
    setState(() {
      _turns.add(UncleTurn(fromUser: false, text: reply));
      _thinking = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final live = AiService.instance.liveActive;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        title: Text('Ask the Uncle 🧓', style: T.display(18, color: Colors.white, weight: FontWeight.w800, spacing: 0)),
      ),
      body: Column(
        children: [
          if (!live)
            Container(
              width: double.infinity,
              color: AppColors.goldBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Offline pretend mode — uncle is improvising from memory.',
                  style: T.body(11.5, color: AppColors.goldText)),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              itemCount: _turns.length + (_thinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _turns.length) return _bubble(const UncleTurn(fromUser: false, text: '…'));
                return _bubble(_turns[i]);
              },
            ),
          ),
          _composer(),
        ],
      ),
    );
  }

  Widget _bubble(UncleTurn t) {
    final mine = t.fromUser;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: mine ? AppColors.red : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Text(t.text, style: T.body(13.5, color: mine ? Colors.white : AppColors.ink, height: 1.4)),
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Complain to the uncle…',
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _thinking ? null : _send,
              style: IconButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
