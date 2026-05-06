// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/lesson_detail.dart';
import '../models/lesson_list_response.dart';

part 'lessons_client.g.dart';

@RestApi()
abstract class LessonsClient {
  factory LessonsClient(Dio dio, {String? baseUrl}) = _LessonsClient;

  /// List lessons with optional category filter.
  ///
  /// Paginated lesson list.
  ///
  /// [category] - Filter by lesson category.
  @GET('/api/v1/lessons')
  Future<LessonListResponse> listLessonsApiV1LessonsGet({
    @Query('limit') int? limit = 30,
    @Query('offset') int? offset = 0,
    @Query('category') String? category,
  });

  /// Single lesson detail by slug.
  ///
  /// Return the full lesson payload for ``slug``.
  @GET('/api/v1/lessons/{slug}')
  Future<LessonDetail> getLessonApiV1LessonsSlugGet({
    @Path('slug') required String slug,
  });
}
