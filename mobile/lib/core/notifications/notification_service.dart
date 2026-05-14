import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

  // Reserved for the "Send a test notification" surface — fires in 5s,
  // never repeats, never collides with the daily schedule.
  static const int _kTestId = 2;
  // Per-day personalised notifs use IDs 100 + offset (0-29). The base
  // is high enough that we can grow the personalised window without
  // colliding with other reserved IDs.
  static const int _kPersonalisedBaseId = 100;
  static const String _kChannelId = 'thaqafa-daily';

  bool _initialised = false;

  /// One-shot init — safe to call multiple times. Loads the timezone
  /// database, **sets ``tz.local`` to the device's IANA zone**, and
  /// configures iOS + Android channels.
  ///
  /// Without ``setLocalLocation``, ``tz.local`` defaults to UTC and
  /// every ``zonedSchedule(tz.TZDateTime(tz.local, …))`` fires
  /// ``utcOffset`` hours late (~2h for ``Europe/Paris`` in summer). This
  /// is *the* gotcha behind the most common "my notification arrived
  /// hours after I expected" report against ``flutter_local_notifications``.
  Future<void> ensureInitialised() async {
    if (_initialised) return;
    tzdata.initializeTimeZones();

    // Resolve the device's IANA timezone (e.g. "Europe/Paris"). On
    // simulators / emulators / desktop this can be ``null`` or
    // ``"UTC"`` — we tolerate failure and fall back to UTC, which is
    // wrong but at least doesn't crash.
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Keep tz.local at its default (UTC). Better visible bug than crash.
    }

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

  /// Check the OS-level notification permission without prompting the
  /// user. Returns ``true`` when notifications are allowed to display.
  /// Used by Settings to warn when the in-app toggle is on but iOS
  /// itself is silencing alerts.
  Future<bool> hasPermission() async {
    await ensureInitialised();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await ios?.checkPermissions();
      return settings?.isAlertEnabled == true || settings?.isSoundEnabled == true;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }
    return false;
  }

  /// Fire a one-shot notification five seconds from now. Used by the
  /// "Send a test notification" button in Settings so users can verify
  /// end-to-end that iOS is willing to surface the alert (permission
  /// granted, Focus mode off, lock-screen settings allow, …) without
  /// waiting for the scheduled daily hour.
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    await ensureInitialised();
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
    final fireAt = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _plugin.zonedSchedule(
      _kTestId,
      title,
      body,
      fireAt,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
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

  /// Schedule (or reschedule) the daily notifications at the given local
  /// hour and minute. Calling with `enabled: false` cancels any pending
  /// schedule and returns.
  ///
  /// ``upcoming`` is a list of ``(title, body)`` pairs, one per day
  /// starting today. Each entry fires once on its specific date as a
  /// one-shot — the user sees a notification like:
  ///
  ///     Today on the calendar
  ///     Death of ʿAbd al-ʿAzīz ibn Bāz — Grand Muftī of Saudi Arabia
  ///
  /// The list typically holds ~7 days; the caller (``rescheduleDaily-
  /// Notifications``) is responsible for filling it (with real headlines
  /// from ``/upcoming`` when the API succeeds, with generic fallback
  /// content when it fails). Once those N one-shots fire, no further
  /// notifications go out until the user reopens the app and a new
  /// window is scheduled.
  ///
  /// **Why no repeating fallback.** An earlier version tacked on a
  /// ``matchDateTimeComponents: DateTimeComponents.time`` notif so
  /// "absent users keep getting reminded". That had two problems:
  ///   1. ``DateTimeComponents.time`` ignores the date portion entirely
  ///      — the OS fires every day at H:M starting from *trigger
  ///      creation*, not from the personalised window's end. So users
  ///      were getting **two notifications per day** for the first
  ///      seven days: the personalised one + the repeater.
  ///   2. A generic "open the app" nag to a disengaged user is the
  ///      single fastest way to make them turn notifications off at
  ///      the OS level — recovering from that is impossible. Apple
  ///      HIG is explicit: "Avoid using notifications for unimportant
  ///      information." A respectful silence after a week of inactivity
  ///      is the right product call.
  Future<void> scheduleDaily({
    required bool enabled,
    required int hour,
    required int minute,
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
  }
}
