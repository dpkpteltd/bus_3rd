import 'package:flutter/material.dart';

import 'app.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.load();

  // Local-only prank notifications; safe no-op if the platform can't init.
  await NotificationService.instance.init();

  runApp(BusApp(appState: appState));
}
