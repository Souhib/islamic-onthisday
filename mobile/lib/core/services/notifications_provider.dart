import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/core/notifications/notification_scheduler.dart';
import 'package:thaqafa/core/notifications/notification_service.dart';

/// Reactive flag for "daily notification enabled". Pushes
/// (re-)schedules through `NotificationService` whenever it flips.
/// Each schedule fetches the next 7 days from ``/api/v1/upcoming`` so
/// the alerts carry the actual headline titles instead of a generic
/// body — see ``rescheduleDailyNotifications``.
class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsServiceProvider).notificationsEnabled;

  Future<void> set(bool value, {required String title, required String body}) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setNotificationsEnabled(value);
    state = value;
    if (value) {
      await NotificationService.instance.requestPermissions();
    }
    await ref.rescheduleDailyNotificationsFromPrefs(
      genericTitle: title,
      genericBody: body,
    );
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

/// Reactive notification time-of-day (0-23h, 0-59min). Reschedules
/// when changed.
class NotificationTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() {
    final prefs = ref.read(prefsServiceProvider);
    return TimeOfDay(hour: prefs.notificationHour, minute: prefs.notificationMinute);
  }

  Future<void> set(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setNotificationHour(time.hour);
    await prefs.setNotificationMinute(time.minute);
    state = time;
    if (prefs.notificationsEnabled) {
      await ref.rescheduleDailyNotificationsFromPrefs(
        genericTitle: title,
        genericBody: body,
      );
    }
  }
}

final notificationTimeProvider =
    NotifierProvider<NotificationTimeNotifier, TimeOfDay>(
  NotificationTimeNotifier.new,
);
