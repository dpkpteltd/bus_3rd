// Tests for Bus 3rd (parody bus app).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bus_3rd/app.dart';
import 'package:bus_3rd/screens/passenger_game_screen.dart';
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
    expect(find.text('Chope'), findsOneWidget);
    expect(find.text('Give Up'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Passenger 2048 board renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PassengerGameScreen())),
    );
    await tester.pump();

    expect(find.text('Passenger 2048'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);

    // A swipe should not throw.
    await tester.fling(find.text('Passenger 2048'), const Offset(0, -200), 1000);
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
  });

  group('slidePassengerLine', () {
    test('merges a pair toward index 0', () {
      final (line, gained) = slidePassengerLine([1, 1, 0, 0]);
      expect(line, [2, 0, 0, 0]);
      expect(gained, tierValue(2));
    });

    test('pulls apart tiles together then merges', () {
      final (line, gained) = slidePassengerLine([1, 0, 1, 0]);
      expect(line, [2, 0, 0, 0]);
      expect(gained, tierValue(2));
    });

    test('only one merge per move', () {
      final (line, gained) = slidePassengerLine([1, 1, 1, 0]);
      expect(line, [2, 1, 0, 0]);
      expect(gained, tierValue(2));
    });

    test('two pairs both merge', () {
      final (line, gained) = slidePassengerLine([2, 2, 2, 2]);
      expect(line, [3, 3, 0, 0]);
      expect(gained, tierValue(3) * 2);
    });

    test('no merge leaves the line compacted only', () {
      final (line, gained) = slidePassengerLine([1, 2, 0, 0]);
      expect(line, [1, 2, 0, 0]);
      expect(gained, 0);
    });

    test('max tier does not merge further', () {
      final (line, gained) = slidePassengerLine([kMaxTier, kMaxTier, 0, 0]);
      expect(line, [kMaxTier, kMaxTier, 0, 0]);
      expect(gained, 0);
    });
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
