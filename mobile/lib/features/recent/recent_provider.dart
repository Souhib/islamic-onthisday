import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/recent_response.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

final recentProvider = FutureProvider<RecentResponse>((ref) async {
  final client = ref.watch(iotdClientProvider).recent;
  return client.getRecentApiV1RecentGet();
});
