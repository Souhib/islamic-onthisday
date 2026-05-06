// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonListResponse _$LessonListResponseFromJson(Map<String, dynamic> json) =>
    LessonListResponse(
      total: (json['total'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => LessonSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LessonListResponseToJson(LessonListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'limit': instance.limit,
      'offset': instance.offset,
    };
