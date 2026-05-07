import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/person_detail.dart';
import 'package:thaqafa/core/di/api_providers.dart';

final personBySlugProvider =
    FutureProvider.autoDispose.family<PersonDetail, String>((ref, slug) async {
  final client = ref.watch(thaqafaClientProvider).people;
  return client.getPersonApiV1PeopleSlugGet(slug: slug);
});
