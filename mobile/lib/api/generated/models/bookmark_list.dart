// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'bookmark_out.dart';

part 'bookmark_list.g.dart';

/// Paginated bookmarks payload.
@JsonSerializable()
class BookmarkList {
  const BookmarkList({
    required this.items,
    required this.total,
  });
  
  factory BookmarkList.fromJson(Map<String, Object?> json) => _$BookmarkListFromJson(json);
  
  final List<BookmarkOut> items;
  final int total;

  Map<String, Object?> toJson() => _$BookmarkListToJson(this);
}
