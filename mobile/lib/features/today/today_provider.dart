import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/today_response.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';
import 'package:iotd_mobile/core/widgets_bridge/home_widget_writer.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';

/// AsyncNotifier-style provider for `/api/v1/today`. Re-fetches when
/// the consumer calls `ref.invalidate(todayProvider)`. Caches inside
/// Riverpod for the lifetime of the screen.
///
/// On every successful fetch we also push the payload to the
/// home-screen widget shared store via `HomeWidgetWriter`. The call
/// is a no-op on platforms / builds where the native widget target
/// is absent, so it's safe to wire unconditionally.
final todayProvider = FutureProvider<TodayResponse>((ref) async {
  final client = ref.watch(iotdClientProvider).today;
  final data = await client.getTodayApiV1TodayGet();
  await HomeWidgetWriter.publishToday(
    data,
    LocaleSettings.currentLocale.languageCode,
  );
  return data;
});
