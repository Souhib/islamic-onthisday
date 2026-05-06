// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'person_detail.g.dart';

/// Full person profile.
///
/// The image policy is enforced upstream by the pipeline: ``image_url`` is.
/// guaranteed to be ``None`` for any prophet, Sahabi, or member of Ahl.
/// al-Bayt. The frontend should not rely on its own check, but the value.
/// is also surfaced explicitly in ``image_blocked_reason`` when applicable.
@JsonSerializable()
class PersonDetail {
  const PersonDetail({
    required this.id,
    required this.fullNameEn,
    this.isProphet = false,
    this.isSahabi = false,
    this.isAhlAlBayt = false,
    this.fullNameAr,
    this.kunya,
    this.laqab,
    this.nisba,
    this.role,
    this.biography,
    this.imageUrl,
    this.imageBlockedReason,
    this.wikidataQid,
  });
  
  factory PersonDetail.fromJson(Map<String, Object?> json) => _$PersonDetailFromJson(json);
  
  final String id;
  final String fullNameEn;
  final String? fullNameAr;
  final String? kunya;
  final String? laqab;
  final String? nisba;
  final String? role;
  final String? biography;
  final bool isProphet;
  final bool isSahabi;
  final bool isAhlAlBayt;
  final String? imageUrl;
  final String? imageBlockedReason;
  final String? wikidataQid;

  Map<String, Object?> toJson() => _$PersonDetailToJson(this);
}
