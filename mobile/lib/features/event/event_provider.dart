import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/event_detail.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

final eventBySlugProvider =
    FutureProvider.autoDispose.family<EventDetail, String>((ref, slug) async {
  final client = ref.watch(iotdClientProvider).events;
  return client.getEventApiV1EventsSlugGet(slug: slug);
});
