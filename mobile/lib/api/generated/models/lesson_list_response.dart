// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_summary.dart';

part 'lesson_list_response.g.dart';

/// Paginated list of lessons.
@JsonSerializable()
class LessonListResponse {
  const LessonListResponse({
    required this.total,
    required this.limit,
    required this.offset,
    this.items = const [],
  });
  
  factory LessonListResponse.fromJson(Map<String, Object?> json) => _$LessonListResponseFromJson(json);
  
  final List<LessonSummary> items;
  final int total;
  final int limit;
  final int offset;

  Map<String, Object?> toJson() => _$LessonListResponseToJson(this);
}
