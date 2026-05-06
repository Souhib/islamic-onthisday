import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/today_response.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

/// AsyncNotifier-style provider for `/api/v1/today`. Re-fetches when
/// the consumer calls `ref.invalidate(todayProvider)`. Caches inside
/// Riverpod for the lifetime of the screen.
final todayProvider = FutureProvider<TodayResponse>((ref) async {
  final client = ref.watch(iotdClientProvider).today;
  return client.getTodayApiV1TodayGet();
});
