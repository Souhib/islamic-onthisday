import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/recent_response.dart';
import 'package:thaqafa/core/di/api_providers.dart';

final recentProvider = FutureProvider<RecentResponse>((ref) async {
  final client = ref.watch(thaqafaClientProvider).recent;
  return client.getRecentApiV1RecentGet();
});
