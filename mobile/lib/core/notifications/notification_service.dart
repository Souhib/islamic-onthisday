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
  // Per-day personalised notifs use IDs 100 + offset (0-29). The base
  // is high enough that we can grow the personalised window without
  // colliding with the repeating fallback at ID 1.
  static const int _kPersonalisedBaseId = 100;
  static const String _kChannelId = 'thaqafa-daily';

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
  /// hour and minute. Calling with `enabled: false` cancels any pending
  /// schedule.
  ///
  /// **Personalised mode (preferred).** Pass ``upcoming`` — a list of
  /// ``(title, body)`` pairs, one per day starting today — to schedule
  /// rich-content one-shots for the next N days. Each entry fires once
  /// on its specific date, so the user sees the actual event title in
  /// the alert ("Today: Death of Maḥmūd of Ghazna"). After the window
  /// runs out, a *repeating* generic notif takes over (``title`` /
  /// ``body``) so the reminder never goes silent for an absent user.
  ///
  /// **Generic-only mode.** Pass ``upcoming = const []`` (or omit) to
  /// fall back to the original behaviour: a single repeating notif
  /// with the static ``title`` / ``body``, fired daily.
  Future<void> scheduleDaily({
    required bool enabled,
    required int hour,
    required int minute,
    required String title,
    required String body,
    List<({String title, String body})> upcoming = const [],
  }) async {
    await ensureInitialised();
    await _plugin.cancelAll();
    if (!enabled) return;

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      android: AndroidNotificationDetails(
        _kChannelId,
        'Daily reading',
        channelDescription: 'One verified Islamic-history event per day.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);

    // Schedule one one-shot per upcoming day (day 0 = today). Skip any
    // slot already in the past so we don't fire immediately on the
    // current day if the user picked an earlier hour than now.
    for (var i = 0; i < upcoming.length; i++) {
      final scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day + i, hour, minute);
      if (!scheduled.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        _kPersonalisedBaseId + i,
        upcoming[i].title,
        upcoming[i].body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    // Schedule the repeating generic notif starting *after* the
    // personalised window. ``matchDateTimeComponents: DateTimeComponents.time``
    // tells the OS to repeat every day at the same hour, so when the
    // app stops being opened the user keeps receiving a (generic)
    // reminder instead of going silent forever.
    final fallbackOffset = upcoming.isEmpty ? 0 : upcoming.length;
    var fallback = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + fallbackOffset,
      hour,
      minute,
    );
    if (!fallback.isAfter(now)) {
      fallback = fallback.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _kDailyId,
      title,
      body,
      fallback,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
