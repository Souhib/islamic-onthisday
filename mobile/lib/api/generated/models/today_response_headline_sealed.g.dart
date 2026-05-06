// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_response_headline_sealed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$TodayResponseHeadlineSealedToJson(
  TodayResponseHeadlineSealed instance,
) => <String, dynamic>{};

TodayResponseHeadlineSealedEventDetail
_$TodayResponseHeadlineSealedEventDetailFromJson(
  Map<String, dynamic> json,
) => TodayResponseHeadlineSealedEventDetail(
  id: json['id'] as String,
  title: json['title'] as String,
  titleAr: json['titleAr'] as String?,
  titleFr: json['titleFr'] as String?,
  era: json['era'] as String?,
  importance: json['importance'] as String,
  verificationStatus: EventDetailVerificationStatus.fromJson(
    json['verificationStatus'] as String,
  ),
  gregorian: json['gregorian'] as String?,
  hijri: json['hijri'] as String?,
  location: json['location'] as String?,
  placeholder: json['placeholder'] as String?,
  noImage: json['noImage'] as bool,
  imageUrl: json['imageUrl'] as String?,
  summary: json['summary'] as String,
  summaryAr: json['summaryAr'] as String?,
  summaryFr: json['summaryFr'] as String?,
  body: (json['body'] as List<dynamic>).map((e) => e as String).toList(),
  bodyAr: (json['bodyAr'] as List<dynamic>).map((e) => e as String).toList(),
  bodyFr: (json['bodyFr'] as List<dynamic>).map((e) => e as String).toList(),
  people: (json['people'] as List<dynamic>)
      .map((e) => PersonRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  sources: (json['sources'] as List<dynamic>)
      .map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  disputed: json['disputed'] as bool,
  disputeAbout: json['disputeAbout'] == null
      ? null
      : EventDetailDisputeAbout.fromJson(json['disputeAbout'] as String),
  disputedPositions: (json['disputedPositions'] as List<dynamic>)
      .map((e) => DisputedPosition.fromJson(e as Map<String, dynamic>))
      .toList(),
  sourceUrl: json['sourceUrl'] as String?,
  quranRefs: json['quranRefs'] as String?,
);

Map<String, dynamic> _$TodayResponseHeadlineSealedEventDetailToJson(
  TodayResponseHeadlineSealedEventDetail instance,
) => <String, dynamic>{
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

TodayResponseHeadlineSealedLessonDetail
_$TodayResponseHeadlineSealedLessonDetailFromJson(
  Map<String, dynamic> json,
) => TodayResponseHeadlineSealedLessonDetail(
  kind: json['kind'] as String,
  id: json['id'] as String,
  title: json['title'] as String,
  titleAr: json['titleAr'] as String?,
  titleFr: json['titleFr'] as String?,
  category: json['category'] as String,
  reference: json['reference'] as String?,
  summary: json['summary'] as String,
  summaryAr: json['summaryAr'] as String?,
  summaryFr: json['summaryFr'] as String?,
  body: (json['body'] as List<dynamic>).map((e) => e as String).toList(),
  bodyAr: (json['bodyAr'] as List<dynamic>).map((e) => e as String).toList(),
  bodyFr: (json['bodyFr'] as List<dynamic>).map((e) => e as String).toList(),
  quranRefs: json['quranRefs'] as String?,
  hadithRefs: json['hadithRefs'] as String?,
  sourceUrl: json['sourceUrl'] as String?,
  sourceNotes: json['sourceNotes'] as String?,
  sourceNotesAr: json['sourceNotesAr'] as String?,
  sourceNotesFr: json['sourceNotesFr'] as String?,
);

Map<String, dynamic> _$TodayResponseHeadlineSealedLessonDetailToJson(
  TodayResponseHeadlineSealedLessonDetail instance,
) => <String, dynamic>{
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
