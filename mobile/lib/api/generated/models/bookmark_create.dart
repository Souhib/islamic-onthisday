// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'bookmark_create_target_kind.dart';

part 'bookmark_create.g.dart';

/// Inputs for ``POST /api/v1/bookmarks``.
@JsonSerializable()
class BookmarkCreate {
  const BookmarkCreate({
    required this.targetKind,
    required this.targetSlug,
    this.note,
  });
  
  factory BookmarkCreate.fromJson(Map<String, Object?> json) => _$BookmarkCreateFromJson(json);
  
  final BookmarkCreateTargetKind targetKind;
  final String targetSlug;
  final String? note;

  Map<String, Object?> toJson() => _$BookmarkCreateToJson(this);
}
