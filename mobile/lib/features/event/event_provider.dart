import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/event_detail.dart';
import 'package:thaqafa/core/di/api_providers.dart';

final eventBySlugProvider =
    FutureProvider.autoDispose.family<EventDetail, String>((ref, slug) async {
  final client = ref.watch(thaqafaClientProvider).events;
  return client.getEventApiV1EventsSlugGet(slug: slug);
});
