import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/fake_data.dart';

/// Wraps flutter_local_notifications for the prank (local-only) notifications.
/// Nothing is sent to or from any server — these are scheduled on-device.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'pranks';
  static const _channelName = 'Pranks';
  static const _channelDesc = 'Silly fake bus notifications';

  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    try {
      await _plugin.initialize(settings: settings);
      _initialised = true;
    } catch (e) {
      // Notifications are non-essential to the app; never crash on init.
      debugPrint('Notification init failed: $e');
    }
  }

  /// Asks the OS for permission. Returns true if (likely) granted.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final iOS = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission() ??
          await iOS?.requestPermissions(alert: true, badge: true, sound: true) ??
          true;
      return granted;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  /// Fire an immediate prank notification with random funny text.
  Future<void> showPrankNow() async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: FakeData.randomPrankTitle(),
        body: FakeData.randomPrankBody(),
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('Show notification failed: $e');
    }
  }
}
