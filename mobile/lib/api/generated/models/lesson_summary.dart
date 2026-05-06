// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lesson_summary.g.dart';

/// Slim lesson projection for rotation rails — trilingual.
@JsonSerializable()
class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    required this.category,
    this.titleAr,
    this.titleFr,
    this.reference,
    this.kind = 'lesson',
  });
  
  factory LessonSummary.fromJson(Map<String, Object?> json) => _$LessonSummaryFromJson(json);
  
  final String kind;
  final String id;
  final String title;
  final String? titleAr;
  final String? titleFr;
  final String category;
  final String? reference;

  Map<String, Object?> toJson() => _$LessonSummaryToJson(this);
}
