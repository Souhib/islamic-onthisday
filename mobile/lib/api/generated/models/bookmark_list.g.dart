// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkList _$BookmarkListFromJson(Map<String, dynamic> json) => BookmarkList(
  items: (json['items'] as List<dynamic>)
      .map((e) => BookmarkOut.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$BookmarkListToJson(BookmarkList instance) =>
    <String, dynamic>{'items': instance.items, 'total': instance.total};
