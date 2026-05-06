import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/observance_detail.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

final observancesListProvider =
    FutureProvider<List<ObservanceDetail>>((ref) async {
  final client = ref.watch(iotdClientProvider).observances;
  return client.listObservancesApiV1ObservancesGet();
});

final observanceBySlugProvider = FutureProvider.autoDispose
    .family<ObservanceDetail, String>((ref, slug) async {
  final client = ref.watch(iotdClientProvider).observances;
  return client.getObservanceApiV1ObservancesSlugGet(slug: slug);
});
