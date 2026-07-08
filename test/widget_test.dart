// Tests for Bus 3rd (parody bus app).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bus_3rd/app.dart';
import 'package:bus_3rd/services/app_state.dart';

void main() {
  testWidgets('Splash -> enter app shows the bottom nav', (tester) async {
    // ai_online:false keeps the smoke test fully offline (no live backend call).
    SharedPreferences.setMockInitialValues({'seen_disclaimer': true, 'ai_online': false});
    final appState = AppState();
    await appState.load();

    await tester.pumpWidget(BusApp(appState: appState));
    await tester.pump();

    final enter = find.text('Aiya, just let me in  →');
    expect(enter, findsOneWidget);

    await tester.tap(enter);
    await tester.pump();
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Drive'), findsOneWidget);
    expect(find.text('Give Up'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  test('AppState persists prank toggle', () async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.load();

    expect(appState.pranksEnabled, isTrue);
    appState.setPranksEnabled(false);
    expect(appState.pranksEnabled, isFalse);
  });
}
