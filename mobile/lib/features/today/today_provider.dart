import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/today_response.dart';
import 'package:thaqafa/core/di/api_providers.dart';
import 'package:thaqafa/core/notifications/notification_scheduler.dart';
import 'package:thaqafa/core/widgets_bridge/home_widget_writer.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// AsyncNotifier-style provider for `/api/v1/today`. Re-fetches when
/// the consumer calls `ref.invalidate(todayProvider)`. Caches inside
/// Riverpod for the lifetime of the screen.
///
/// Side-effects on every successful fetch:
///   1. Push the payload to the home-screen widget shared store
///      via ``HomeWidgetWriter`` (no-op when the native widget
///      target isn't installed).
///   2. Re-fetch the next 7 days from ``/api/v1/upcoming`` and
///      reschedule local notifications so the alerts carry the
///      actual headline titles. Non-blocking — failure here
///      degrades silently to whatever was previously scheduled.
final todayProvider = FutureProvider<TodayResponse>((ref) async {
  final client = ref.watch(thaqafaClientProvider).today;
  final data = await client.getTodayApiV1TodayGet();
  final lang = LocaleSettings.currentLocale.languageCode;
  await HomeWidgetWriter.publishToday(data, lang);

  // Fire-and-forget: refresh the personalised notification window.
  // Errors land on the unhandled-future stream and are swallowed by
  // the scheduler's internal try/except — the user's current schedule
  // stays in place if anything goes wrong.
  unawaited(
    ref.rescheduleDailyNotificationsFromPrefs(
      genericTitle: _genericTitle(lang),
      genericBody: _genericBody(lang),
    ),
  );

  return data;
});

/// Mirror of ``i18n.settings.notification_title`` keyed off the
/// resolved locale, since this provider runs outside a widget tree
/// and can't take a ``BuildContext``.
String _genericTitle(String lang) => switch (lang) {
      'fr' => "Aujourd'hui dans le calendrier",
      'ar' => 'اليوم في التقويم',
      _ => 'Today on the calendar',
    };

String _genericBody(String lang) => switch (lang) {
      'fr' => 'Une nouvelle entrée vous attend. Ouvrez pour lire.',
      'ar' => 'مدخل جديد في انتظارك. افتح لتقرأ.',
      _ => 'A new entry awaits. Open to read.',
    };
