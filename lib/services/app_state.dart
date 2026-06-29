import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide flags, persisted with shared_preferences. No personal data is
/// stored — only whether the parody disclaimer has been seen and whether the
/// (local-only) prank notifications are enabled.
class AppState extends ChangeNotifier {
  static const _kPranks = 'pranks_enabled';
  static const _kSeenDisclaimer = 'seen_disclaimer';

  bool _pranksEnabled = true;
  bool _seenDisclaimer = false;

  bool get pranksEnabled => _pranksEnabled;
  bool get seenDisclaimer => _seenDisclaimer;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    _pranksEnabled = p.getBool(_kPranks) ?? true;
    _seenDisclaimer = p.getBool(_kSeenDisclaimer) ?? false;
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
