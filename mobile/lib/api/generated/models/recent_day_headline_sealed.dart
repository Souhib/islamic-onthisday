// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'disputed_position.dart';
import 'event_detail_dispute_about.dart';
import 'event_detail_verification_status.dart';
import 'person_ref.dart';
import 'source_ref.dart';
import 'event_detail.dart';
import 'lesson_detail.dart';


part 'recent_day_headline_sealed.g.dart';

@JsonSerializable(createFactory: false)
sealed class RecentDayHeadlineSealed {
  const RecentDayHeadlineSealed();
  
  factory RecentDayHeadlineSealed.fromJson(Map<String, dynamic> json) =>
      RecentDayHeadlineSealedDeserializer.tryDeserialize(json);
  
  Map<String, dynamic> toJson();
}

extension RecentDayHeadlineSealedDeserializer on RecentDayHeadlineSealed {
  static RecentDayHeadlineSealed tryDeserialize(Map<String, dynamic> json) {
    try {
      return RecentDayHeadlineSealedEventDetail.fromJson(json);
    } catch (_) {}
    try {
      return RecentDayHeadlineSealedLessonDetail.fromJson(json);
    } catch (_) {}


    throw FormatException('Could not determine the correct type for RecentDayHeadlineSealed from: $json');
  }
}

@JsonSerializable()
class RecentDayHeadlineSealedEventDetail extends RecentDayHeadlineSealed implements EventDetail {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? titleAr;
  @override
  final String? titleFr;
  @override
  final String? era;
  @override
  final String importance;
  @override
  final EventDetailVerificationStatus verificationStatus;
  @override
  final String? gregorian;
  @override
  final String? hijri;
  @override
  final String? location;
  @override
  final String? placeholder;
  @override
  final bool noImage;
  @override
  final String? imageUrl;
  @override
  final String summary;
  @override
  final String? summaryAr;
  @override
  final String? summaryFr;
  @override
  final List<String> body;
  @override
  final List<String> bodyAr;
  @override
  final List<String> bodyFr;
  @override
  final List<PersonRef> people;
  @override
  final List<SourceRef> sources;
  @override
  final bool disputed;
  @override
  final EventDetailDisputeAbout? disputeAbout;
  @override
  final List<DisputedPosition> disputedPositions;
  @override
  final String? sourceUrl;
  @override
  final String? quranRefs;

  const RecentDayHeadlineSealedEventDetail({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.era,
    required this.importance,
    required this.verificationStatus,
    required this.gregorian,
    required this.hijri,
    required this.location,
    required this.placeholder,
    required this.noImage,
    required this.imageUrl,
    required this.summary,
    required this.summaryAr,
    required this.summaryFr,
    required this.body,
    required this.bodyAr,
    required this.bodyFr,
    required this.people,
    required this.sources,
    required this.disputed,
    required this.disputeAbout,
    required this.disputedPositions,
    required this.sourceUrl,
    required this.quranRefs,
  });
  
  factory RecentDayHeadlineSealedEventDetail.fromJson(Map<String, dynamic> json) =>
      _$RecentDayHeadlineSealedEventDetailFromJson(json);
      
  @override
  Map<String, dynamic> toJson() => _$RecentDayHeadlineSealedEventDetailToJson(this);
}
@JsonSerializable()
class RecentDayHeadlineSealedLessonDetail extends RecentDayHeadlineSealed implements LessonDetail {
  @override
  final String kind;
  @override
  final String id;
  @override
  final String title;
  @override
  final String? titleAr;
  @override
  final String? titleFr;
  @override
  final String category;
  @override
  final String? reference;
  @override
  final String summary;
  @override
  final String? summaryAr;
  @override
  final String? summaryFr;
  @override
  final List<String> body;
  @override
  final List<String> bodyAr;
  @override
  final List<String> bodyFr;
  @override
  final String? quranRefs;
  @override
  final String? hadithRefs;
  @override
  final String? sourceUrl;
  @override
  final String? sourceNotes;
  @override
  final String? sourceNotesAr;
  @override
  final String? sourceNotesFr;

  const RecentDayHeadlineSealedLessonDetail({
    required this.kind,
    required this.id,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.category,
    required this.reference,
    required this.summary,
    required this.summaryAr,
    required this.summaryFr,
    required this.body,
    required this.bodyAr,
    required this.bodyFr,
    required this.quranRefs,
    required this.hadithRefs,
    required this.sourceUrl,
    required this.sourceNotes,
    required this.sourceNotesAr,
    required this.sourceNotesFr,
  });
  
  factory RecentDayHeadlineSealedLessonDetail.fromJson(Map<String, dynamic> json) =>
      _$RecentDayHeadlineSealedLessonDetailFromJson(json);
      
  @override
  Map<String, dynamic> toJson() => _$RecentDayHeadlineSealedLessonDetailToJson(this);
}
