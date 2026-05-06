// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'observance_detail.g.dart';

/// A recurring Hijri-anchored Islamic observance (Eid, Mawlid, Arafah, …).
///
/// Trilingual: ``name``/``name_ar``/``name_fr`` and.
/// ``description``/``description_ar``/``description_fr``.
@JsonSerializable()
class ObservanceDetail {
  const ObservanceDetail({
    required this.id,
    required this.nameEn,
    required this.descriptionEn,
    required this.hijriMonth,
    required this.importance,
    this.windowDays = 1,
    this.nameAr,
    this.nameFr,
    this.descriptionAr,
    this.descriptionFr,
    this.hijriDay,
    this.quranRefs,
    this.hadithRefs,
  });
  
  factory ObservanceDetail.fromJson(Map<String, Object?> json) => _$ObservanceDetailFromJson(json);
  
  final String id;
  final String nameEn;
  final String? nameAr;
  final String? nameFr;
  final String descriptionEn;
  final String? descriptionAr;
  final String? descriptionFr;
  final int hijriMonth;
  final int? hijriDay;
  final int windowDays;
  final String importance;
  final String? quranRefs;
  final String? hadithRefs;

  Map<String, Object?> toJson() => _$ObservanceDetailToJson(this);
}
