import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/di/providers.dart';
import 'package:iotd_mobile/core/notifications/notification_service.dart';

/// Reactive flag for "daily notification enabled". Pushes
/// (re-)schedules through `NotificationService` whenever it flips.
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
    await NotificationService.instance.scheduleDaily(
      enabled: value,
      hour: prefs.notificationHour,
      minute: prefs.notificationMinute,
      title: title,
      body: body,
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
      await NotificationService.instance.scheduleDaily(
        enabled: true,
        hour: time.hour,
        minute: time.minute,
        title: title,
        body: body,
      );
    }
  }
}

final notificationTimeProvider =
    NotifierProvider<NotificationTimeNotifier, TimeOfDay>(
  NotificationTimeNotifier.new,
);
