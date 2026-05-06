// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_summary_dispute_about.dart';
import 'event_summary_verification_status.dart';
import 'event_summary.dart';
import 'lesson_summary.dart';


part 'today_response_secondary_sealed.g.dart';

@JsonSerializable(createFactory: false)
sealed class TodayResponseSecondarySealed {
  const TodayResponseSecondarySealed();
  
  factory TodayResponseSecondarySealed.fromJson(Map<String, dynamic> json) =>
      TodayResponseSecondarySealedDeserializer.tryDeserialize(json);
  
  Map<String, dynamic> toJson();
}

extension TodayResponseSecondarySealedDeserializer on TodayResponseSecondarySealed {
  static TodayResponseSecondarySealed tryDeserialize(Map<String, dynamic> json) {
    try {
      return TodayResponseSecondarySealedEventSummary.fromJson(json);
    } catch (_) {}
    try {
      return TodayResponseSecondarySealedLessonSummary.fromJson(json);
    } catch (_) {}


    throw FormatException('Could not determine the correct type for TodayResponseSecondarySealed from: $json');
  }
}

@JsonSerializable()
class TodayResponseSecondarySealedEventSummary extends TodayResponseSecondarySealed implements EventSummary {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? titleAr;
  @override
  final String? titleFr;
  @override
  final String? hijri;
  @override
  final String? gregorian;
  @override
  final String? era;
  @override
  final String importance;
  @override
  final EventSummaryVerificationStatus verificationStatus;
  @override
  final bool disputed;
  @override
  final EventSummaryDisputeAbout? disputeAbout;

  const TodayResponseSecondarySealedEventSummary({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.hijri,
    required this.gregorian,
    required this.era,
    required this.importance,
    required this.verificationStatus,
    required this.disputed,
    required this.disputeAbout,
  });
  
  factory TodayResponseSecondarySealedEventSummary.fromJson(Map<String, dynamic> json) =>
      _$TodayResponseSecondarySealedEventSummaryFromJson(json);
      
  @override
  Map<String, dynamic> toJson() => _$TodayResponseSecondarySealedEventSummaryToJson(this);
}
@JsonSerializable()
class TodayResponseSecondarySealedLessonSummary extends TodayResponseSecondarySealed implements LessonSummary {
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

  const TodayResponseSecondarySealedLessonSummary({
    required this.kind,
    required this.id,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.category,
    required this.reference,
  });
  
  factory TodayResponseSecondarySealedLessonSummary.fromJson(Map<String, dynamic> json) =>
      _$TodayResponseSecondarySealedLessonSummaryFromJson(json);
      
  @override
  Map<String, dynamic> toJson() => _$TodayResponseSecondarySealedLessonSummaryToJson(this);
}
