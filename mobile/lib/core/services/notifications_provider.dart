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
      title: title,
      body: body,
    );
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

/// Reactive notification hour (0–23). Reschedules when changed.
class NotificationHourNotifier extends Notifier<int> {
  @override
  int build() => ref.read(prefsServiceProvider).notificationHour;

  Future<void> set(int hour, {required String title, required String body}) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setNotificationHour(hour);
    state = hour;
    if (prefs.notificationsEnabled) {
      await NotificationService.instance.scheduleDaily(
        enabled: true,
        hour: hour,
        title: title,
        body: body,
      );
    }
  }
}

final notificationHourProvider =
    NotifierProvider<NotificationHourNotifier, int>(NotificationHourNotifier.new);
