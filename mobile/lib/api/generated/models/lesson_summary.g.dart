// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonSummary _$LessonSummaryFromJson(Map<String, dynamic> json) =>
    LessonSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      titleAr: json['titleAr'] as String?,
      titleFr: json['titleFr'] as String?,
      reference: json['reference'] as String?,
      kind: json['kind'] as String? ?? 'lesson',
    );

Map<String, dynamic> _$LessonSummaryToJson(LessonSummary instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'titleFr': instance.titleFr,
      'category': instance.category,
      'reference': instance.reference,
    };
