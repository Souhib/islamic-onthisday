import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/thaqafa_client.dart';
import 'package:thaqafa/api/generated/models/recent_day.dart';
import 'package:thaqafa/api/generated/models/recent_day_headline_sealed.dart';
import 'package:thaqafa/core/di/api_providers.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/core/notifications/notification_service.dart';
import 'package:thaqafa/core/storage/preferences_service.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// Default pre-fetch window. Seven covers the user that opens the app
/// once a week without breaking iOS' 64-pending-notification ceiling
/// (we use 7 + 1 fallback = 8 slots out of 64).
const int kPersonalisedNotifWindow = 7;

/// Fetch the next ``window`` upcoming days and reschedule local
/// notifications: ``window`` rich one-shots with the actual day's
/// headline title baked in. Once those fire, no further notifications
/// go out until the user reopens the app — the window is renewed on
/// each open.
///
/// Called from two places:
///   - bootstrap, after the user-visible state is ready (so a fresh
///     install picks up its 7-day window before the user even opens
///     Settings),
///   - any time the user toggles notifications on or changes the
///     hour/minute (handled in ``NotificationsEnabledNotifier`` /
///     ``NotificationTimeNotifier``).
///
/// **Failure mode.** If the ``/upcoming`` fetch fails (offline, server
/// down, …), we still schedule ``window`` days of *generic* one-shots
/// using ``genericTitle`` / ``genericBody``. The user still gets a
/// daily reminder, just without the per-day headline preview. No
/// repeating "open the app" notification — see
/// ``NotificationService.scheduleDaily`` for the rationale.
Future<void> rescheduleDailyNotifications({
  required ThaqafaClient client,
  required PreferencesService prefs,
  required AppLocale locale,
  required String genericTitle,
  required String genericBody,
}) async {
  final hour = prefs.notificationHour;
  final minute = prefs.notificationMinute;

  if (!prefs.notificationsEnabled) {
    await NotificationService.instance.scheduleDaily(
      enabled: false,
      hour: hour,
      minute: minute,
    );
    return;
  }

  List<({String title, String body})> upcoming = const [];
  try {
    final response = await client.upcoming
        .getUpcomingApiV1UpcomingGet(days: kPersonalisedNotifWindow);
    upcoming = [
      for (final day in response.days)
        if (_titleOf(day, locale.languageCode) case final t?)
          (title: genericTitle, body: t),
    ];
  } catch (_) {
    // Best-effort: fall through to generic-only schedule.
  }

  // If the API didn't give us any headlines (network failure, no entries
  // for the next N days, all entries failed the language filter…),
  // schedule a generic notification per day so the daily reminder
  // still goes out. Same shape as the personalised list, just with
  // ``genericBody`` instead of the headline title.
  if (upcoming.isEmpty) {
    upcoming = [
      for (var i = 0; i < kPersonalisedNotifWindow; i++)
        (title: genericTitle, body: genericBody),
    ];
  }

  // Re-check the kill-switch *after* the upcoming fetch resolves.
  // Without this, a user who toggled notifications off while the
  // network roundtrip was in flight would have their schedule re-armed
  // here — the toggle's own ``cancelAll`` already ran, but this path
  // would race in behind it and re-create the notifications.
  if (!prefs.notificationsEnabled) {
    await NotificationService.instance.scheduleDaily(
      enabled: false,
      hour: hour,
      minute: minute,
    );
    return;
  }

  await NotificationService.instance.scheduleDaily(
    enabled: true,
    hour: hour,
    minute: minute,
    upcoming: upcoming,
  );
}

String? _titleOf(RecentDay day, String lang) {
  final h = day.headline;
  if (h is RecentDayHeadlineSealedEventDetail) {
    return _pick(lang, h.title, h.titleAr, h.titleFr);
  }
  if (h is RecentDayHeadlineSealedLessonDetail) {
    return _pick(lang, h.title, h.titleAr, h.titleFr);
  }
  return null;
}

String _pick(String lang, String en, String? ar, String? fr) => switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

Future<void> _rescheduleVia({
  required ThaqafaClient Function() readClient,
  required PreferencesService Function() readPrefs,
  required String genericTitle,
  required String genericBody,
}) async {
  await rescheduleDailyNotifications(
    client: readClient(),
    prefs: readPrefs(),
    locale: LocaleSettings.currentLocale,
    genericTitle: genericTitle,
    genericBody: genericBody,
  );
}

/// Convenience for callers that already have a Riverpod ``Ref`` (i.e.
/// inside a Notifier or a provider) and just want to bounce the
/// schedule off the current preferences.
extension RescheduleFromPrefs on Ref {
  Future<void> rescheduleDailyNotificationsFromPrefs({
    required String genericTitle,
    required String genericBody,
  }) =>
      _rescheduleVia(
        readClient: () => read(thaqafaClientProvider),
        readPrefs: () => read(prefsServiceProvider),
        genericTitle: genericTitle,
        genericBody: genericBody,
      );
}

/// Same convenience but for the widget-level ``WidgetRef``. Onboarding
/// and any other ``ConsumerStatefulWidget`` reaches the scheduler
/// through this surface.
extension RescheduleFromPrefsWidget on WidgetRef {
  Future<void> rescheduleDailyNotificationsFromPrefs({
    required String genericTitle,
    required String genericBody,
  }) =>
      _rescheduleVia(
        readClient: () => read(thaqafaClientProvider),
        readPrefs: () => read(prefsServiceProvider),
        genericTitle: genericTitle,
        genericBody: genericBody,
      );
}
