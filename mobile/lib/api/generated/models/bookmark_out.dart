// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'bookmark_out_target_kind.dart';

part 'bookmark_out.g.dart';

/// A single bookmark — what the saves list returns.
@JsonSerializable()
class BookmarkOut {
  const BookmarkOut({
    required this.id,
    required this.targetKind,
    required this.targetSlug,
    required this.targetTitle,
    required this.targetTitleAr,
    required this.targetTitleFr,
    required this.note,
    required this.createdAt,
  });
  
  factory BookmarkOut.fromJson(Map<String, Object?> json) => _$BookmarkOutFromJson(json);
  
  final String id;
  final BookmarkOutTargetKind targetKind;
  final String targetSlug;
  final String? targetTitle;
  final String? targetTitleAr;
  final String? targetTitleFr;
  final String? note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$BookmarkOutToJson(this);
}
