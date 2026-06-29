import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai/ai_service.dart';

/// App-wide flags, persisted with shared_preferences. No personal data is
/// stored — only whether the parody disclaimer has been seen, whether the
/// (local-only) prank notifications are enabled, and whether the user has
/// opted in to online AI mode.
class AppState extends ChangeNotifier {
  static const _kPranks = 'pranks_enabled';
  static const _kSeenDisclaimer = 'seen_disclaimer';
  static const _kAiOnline = 'ai_online';

  bool _pranksEnabled = true;
  bool _seenDisclaimer = false;
  // Off by default: the app stays fully offline until the user opts in.
  bool _aiOnline = false;

  bool get pranksEnabled => _pranksEnabled;
  bool get seenDisclaimer => _seenDisclaimer;
  bool get aiOnline => _aiOnline;

  /// Whether a backend was compiled in at all (controls showing the toggle).
  bool get aiConfigured => AiService.instance.isConfigured;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    _pranksEnabled = p.getBool(_kPranks) ?? true;
    _seenDisclaimer = p.getBool(_kSeenDisclaimer) ?? false;
    _aiOnline = p.getBool(_kAiOnline) ?? false;
    AiService.instance.online = _aiOnline;
    notifyListeners();
  }

  void setPranksEnabled(bool value) {
    _pranksEnabled = value;
    _prefs?.setBool(_kPranks, value);
    notifyListeners();
  }

  void markDisclaimerSeen() {
    _seenDisclaimer = true;
    _prefs?.setBool(_kSeenDisclaimer, true);
    notifyListeners();
  }

  void setAiOnline(bool value) {
    _aiOnline = value;
    AiService.instance.online = value;
    _prefs?.setBool(_kAiOnline, value);
    notifyListeners();
  }
}

/// Makes [AppState] available to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope?.notifier != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
