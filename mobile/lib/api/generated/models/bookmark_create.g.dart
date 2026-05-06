// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkCreate _$BookmarkCreateFromJson(Map<String, dynamic> json) =>
    BookmarkCreate(
      targetKind: BookmarkCreateTargetKind.fromJson(
        json['targetKind'] as String,
      ),
      targetSlug: json['targetSlug'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$BookmarkCreateToJson(BookmarkCreate instance) =>
    <String, dynamic>{
      'targetKind': _$BookmarkCreateTargetKindEnumMap[instance.targetKind]!,
      'targetSlug': instance.targetSlug,
      'note': instance.note,
    };

const _$BookmarkCreateTargetKindEnumMap = {
  BookmarkCreateTargetKind.event: 'event',
  BookmarkCreateTargetKind.lesson: 'lesson',
  BookmarkCreateTargetKind.observance: 'observance',
  BookmarkCreateTargetKind.person: 'person',
  BookmarkCreateTargetKind.$unknown: r'$unknown',
};
