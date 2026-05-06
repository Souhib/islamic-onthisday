import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/recent_response.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

/// Pre-fetch the next ``days`` calendar days (default 7) to seed
/// rich-content local notifications. Mobile schedules one notif per
/// upcoming day with the actual headline title baked into the body —
/// see ``NotificationService.schedulePersonalisedDaily``.
final upcomingProvider =
    FutureProvider.autoDispose.family<RecentResponse, int>((ref, days) async {
  final client = ref.watch(iotdClientProvider).upcoming;
  return client.getUpcomingApiV1UpcomingGet(days: days);
});
