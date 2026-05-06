// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonDetail _$LessonDetailFromJson(Map<String, dynamic> json) => LessonDetail(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  summary: json['summary'] as String,
  titleAr: json['titleAr'] as String?,
  titleFr: json['titleFr'] as String?,
  reference: json['reference'] as String?,
  summaryAr: json['summaryAr'] as String?,
  summaryFr: json['summaryFr'] as String?,
  quranRefs: json['quranRefs'] as String?,
  hadithRefs: json['hadithRefs'] as String?,
  sourceUrl: json['sourceUrl'] as String?,
  sourceNotes: json['sourceNotes'] as String?,
  sourceNotesAr: json['sourceNotesAr'] as String?,
  sourceNotesFr: json['sourceNotesFr'] as String?,
  kind: json['kind'] as String? ?? 'lesson',
  body:
      (json['body'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bodyAr:
      (json['bodyAr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bodyFr:
      (json['bodyFr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$LessonDetailToJson(LessonDetail instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'titleFr': instance.titleFr,
      'category': instance.category,
      'reference': instance.reference,
      'summary': instance.summary,
      'summaryAr': instance.summaryAr,
      'summaryFr': instance.summaryFr,
      'body': instance.body,
      'bodyAr': instance.bodyAr,
      'bodyFr': instance.bodyFr,
      'quranRefs': instance.quranRefs,
      'hadithRefs': instance.hadithRefs,
      'sourceUrl': instance.sourceUrl,
      'sourceNotes': instance.sourceNotes,
      'sourceNotesAr': instance.sourceNotesAr,
      'sourceNotesFr': instance.sourceNotesFr,
    };
