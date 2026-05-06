import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/lesson_detail.dart';
import 'package:iotd_mobile/core/di/api_providers.dart';

final lessonBySlugProvider =
    FutureProvider.autoDispose.family<LessonDetail, String>((ref, slug) async {
  final client = ref.watch(iotdClientProvider).lessons;
  return client.getLessonApiV1LessonsSlugGet(slug: slug);
});
