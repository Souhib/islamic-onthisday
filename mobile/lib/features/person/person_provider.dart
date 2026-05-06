import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/person_detail.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

final personBySlugProvider =
    FutureProvider.autoDispose.family<PersonDetail, String>((ref, slug) async {
  final client = ref.watch(iotdClientProvider).people;
  return client.getPersonApiV1PeopleSlugGet(slug: slug);
});
