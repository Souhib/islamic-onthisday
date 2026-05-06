// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSummary _$EventSummaryFromJson(Map<String, dynamic> json) => EventSummary(
  id: json['id'] as String,
  title: json['title'] as String,
  importance: json['importance'] as String,
  verificationStatus: EventSummaryVerificationStatus.fromJson(
    json['verificationStatus'] as String,
  ),
  disputed: json['disputed'] as bool? ?? false,
  titleAr: json['titleAr'] as String?,
  titleFr: json['titleFr'] as String?,
  hijri: json['hijri'] as String?,
  gregorian: json['gregorian'] as String?,
  era: json['era'] as String?,
  disputeAbout: json['disputeAbout'] == null
      ? null
      : EventSummaryDisputeAbout.fromJson(json['disputeAbout'] as String),
);

Map<String, dynamic> _$EventSummaryToJson(EventSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'titleFr': instance.titleFr,
      'hijri': instance.hijri,
      'gregorian': instance.gregorian,
      'era': instance.era,
      'importance': instance.importance,
      'verificationStatus':
          _$EventSummaryVerificationStatusEnumMap[instance.verificationStatus]!,
      'disputed': instance.disputed,
      'disputeAbout': _$EventSummaryDisputeAboutEnumMap[instance.disputeAbout],
    };

const _$EventSummaryVerificationStatusEnumMap = {
  EventSummaryVerificationStatus.scholarReviewed: 'scholar_reviewed',
  EventSummaryVerificationStatus.crossVerified: 'cross_verified',
  EventSummaryVerificationStatus.singleSource: 'single_source',
  EventSummaryVerificationStatus.unverified: 'unverified',
  EventSummaryVerificationStatus.$unknown: r'$unknown',
};

const _$EventSummaryDisputeAboutEnumMap = {
  EventSummaryDisputeAbout.date: 'date',
  EventSummaryDisputeAbout.detail: 'detail',
  EventSummaryDisputeAbout.interpretation: 'interpretation',
  EventSummaryDisputeAbout.$unknown: r'$unknown',
};
