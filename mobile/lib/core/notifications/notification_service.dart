import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wraps `flutter_local_notifications` with the two operations the
/// rest of the app cares about:
///   - request permission (iOS only — Android grants on install for
///     SDK < 33; on 33+ requests through the native sheet)
///   - schedule a single repeating daily notification at a chosen
///     local hour
///
/// Phase 3 keeps it minimal: one notification per day, no payload
/// beyond the localised generic body. The MarionetteBinding /
/// notifications interplay can be revisited if anything breaks in
/// debug.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _kDailyId = 1;
  static const String _kChannelId = 'iotd-daily';

  bool _initialised = false;

  /// One-shot init — safe to call multiple times. Loads the timezone
  /// database, configures iOS + Android channels.
  Future<void> ensureInitialised() async {
    if (_initialised) return;
    tzdata.initializeTimeZones();

    const initIos = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(iOS: initIos, android: initAndroid),
    );
    _initialised = true;
  }

  /// Ask the OS for notification permission. Returns true if granted.
  Future<bool> requestPermissions() async {
    await ensureInitialised();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    return false;
  }

  /// Schedule (or reschedule) the daily notification at the given local
  /// hour. Calling with `enabled: false` cancels any pending schedule.
  Future<void> scheduleDaily({
    required bool enabled,
    required int hour,
    required String title,
    required String body,
  }) async {
    await ensureInitialised();
    await _plugin.cancel(_kDailyId);
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _kDailyId,
      title,
      body,
      first,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
        android: AndroidNotificationDetails(
          _kChannelId,
          'Daily reading',
          channelDescription: 'One verified Islamic-history event per day.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
