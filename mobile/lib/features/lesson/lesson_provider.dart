import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/lesson_detail.dart';
import 'package:thaqafa/core/di/api_providers.dart';

final lessonBySlugProvider =
    FutureProvider.autoDispose.family<LessonDetail, String>((ref, slug) async {
  final client = ref.watch(thaqafaClientProvider).lessons;
  return client.getLessonApiV1LessonsSlugGet(slug: slug);
});
