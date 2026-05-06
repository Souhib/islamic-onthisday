// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDetail _$EventDetailFromJson(Map<String, dynamic> json) => EventDetail(
  id: json['id'] as String,
  title: json['title'] as String,
  importance: json['importance'] as String,
  verificationStatus: EventDetailVerificationStatus.fromJson(
    json['verificationStatus'] as String,
  ),
  summary: json['summary'] as String,
  noImage: json['noImage'] as bool? ?? false,
  body:
      (json['body'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bodyAr:
      (json['bodyAr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bodyFr:
      (json['bodyFr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  people:
      (json['people'] as List<dynamic>?)
          ?.map((e) => PersonRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  disputed: json['disputed'] as bool? ?? false,
  disputedPositions:
      (json['disputedPositions'] as List<dynamic>?)
          ?.map((e) => DisputedPosition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  titleAr: json['titleAr'] as String?,
  titleFr: json['titleFr'] as String?,
  era: json['era'] as String?,
  gregorian: json['gregorian'] as String?,
  hijri: json['hijri'] as String?,
  location: json['location'] as String?,
  placeholder: json['placeholder'] as String?,
  imageUrl: json['imageUrl'] as String?,
  summaryAr: json['summaryAr'] as String?,
  summaryFr: json['summaryFr'] as String?,
  disputeAbout: json['disputeAbout'] == null
      ? null
      : EventDetailDisputeAbout.fromJson(json['disputeAbout'] as String),
  sourceUrl: json['sourceUrl'] as String?,
  quranRefs: json['quranRefs'] as String?,
);

Map<String, dynamic> _$EventDetailToJson(EventDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'titleFr': instance.titleFr,
      'era': instance.era,
      'importance': instance.importance,
      'verificationStatus':
          _$EventDetailVerificationStatusEnumMap[instance.verificationStatus]!,
      'gregorian': instance.gregorian,
      'hijri': instance.hijri,
      'location': instance.location,
      'placeholder': instance.placeholder,
      'noImage': instance.noImage,
      'imageUrl': instance.imageUrl,
      'summary': instance.summary,
      'summaryAr': instance.summaryAr,
      'summaryFr': instance.summaryFr,
      'body': instance.body,
      'bodyAr': instance.bodyAr,
      'bodyFr': instance.bodyFr,
      'people': instance.people,
      'sources': instance.sources,
      'disputed': instance.disputed,
      'disputeAbout': _$EventDetailDisputeAboutEnumMap[instance.disputeAbout],
      'disputedPositions': instance.disputedPositions,
      'sourceUrl': instance.sourceUrl,
      'quranRefs': instance.quranRefs,
    };

const _$EventDetailVerificationStatusEnumMap = {
  EventDetailVerificationStatus.scholarReviewed: 'scholar_reviewed',
  EventDetailVerificationStatus.crossVerified: 'cross_verified',
  EventDetailVerificationStatus.singleSource: 'single_source',
  EventDetailVerificationStatus.unverified: 'unverified',
  EventDetailVerificationStatus.$unknown: r'$unknown',
};

const _$EventDetailDisputeAboutEnumMap = {
  EventDetailDisputeAbout.date: 'date',
  EventDetailDisputeAbout.detail: 'detail',
  EventDetailDisputeAbout.interpretation: 'interpretation',
  EventDetailDisputeAbout.$unknown: r'$unknown',
};
