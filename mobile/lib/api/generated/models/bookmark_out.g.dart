// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkOut _$BookmarkOutFromJson(Map<String, dynamic> json) => BookmarkOut(
  id: json['id'] as String,
  targetKind: BookmarkOutTargetKind.fromJson(json['targetKind'] as String),
  targetSlug: json['targetSlug'] as String,
  targetTitle: json['targetTitle'] as String?,
  targetTitleAr: json['targetTitleAr'] as String?,
  targetTitleFr: json['targetTitleFr'] as String?,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookmarkOutToJson(BookmarkOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetKind': _$BookmarkOutTargetKindEnumMap[instance.targetKind]!,
      'targetSlug': instance.targetSlug,
      'targetTitle': instance.targetTitle,
      'targetTitleAr': instance.targetTitleAr,
      'targetTitleFr': instance.targetTitleFr,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$BookmarkOutTargetKindEnumMap = {
  BookmarkOutTargetKind.event: 'event',
  BookmarkOutTargetKind.lesson: 'lesson',
  BookmarkOutTargetKind.observance: 'observance',
  BookmarkOutTargetKind.person: 'person',
  BookmarkOutTargetKind.$unknown: r'$unknown',
};
