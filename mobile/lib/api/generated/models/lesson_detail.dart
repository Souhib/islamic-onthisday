// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lesson_detail.g.dart';

/// Full lesson projection used by the headline + lesson-detail surfaces.
///
/// Trilingual: ``title`` (English) + ``title_ar`` (Arabic) + ``title_fr``.
/// (French) all surfaced; ``summary`` and ``body`` likewise. Front-end.
/// chooses which to render.
@JsonSerializable()
class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    this.titleAr,
    this.titleFr,
    this.reference,
    this.summaryAr,
    this.summaryFr,
    this.quranRefs,
    this.hadithRefs,
    this.sourceUrl,
    this.sourceNotes,
    this.sourceNotesAr,
    this.sourceNotesFr,
    this.kind = 'lesson',
    this.body = const [],
    this.bodyAr = const [],
    this.bodyFr = const [],
  });
  
  factory LessonDetail.fromJson(Map<String, Object?> json) => _$LessonDetailFromJson(json);
  
  final String kind;
  final String id;
  final String title;
  final String? titleAr;
  final String? titleFr;
  final String category;
  final String? reference;
  final String summary;
  final String? summaryAr;
  final String? summaryFr;
  final List<String> body;
  final List<String> bodyAr;
  final List<String> bodyFr;
  final String? quranRefs;
  final String? hadithRefs;
  final String? sourceUrl;
  final String? sourceNotes;
  final String? sourceNotesAr;
  final String? sourceNotesFr;

  Map<String, Object?> toJson() => _$LessonDetailToJson(this);
}
