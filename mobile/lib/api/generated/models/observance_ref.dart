// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'observance_ref.g.dart';

/// Active annual observance, if one is in season.
@JsonSerializable()
class ObservanceRef {
  const ObservanceRef({
    required this.id,
    required this.name,
    required this.hijriDate,
    this.nameAr,
    this.nameFr,
    this.summary,
    this.summaryAr,
    this.summaryFr,
  });
  
  factory ObservanceRef.fromJson(Map<String, Object?> json) => _$ObservanceRefFromJson(json);
  
  final String id;
  final String name;
  final String? nameAr;
  final String? nameFr;
  final String hijriDate;
  final String? summary;
  final String? summaryAr;
  final String? summaryFr;

  Map<String, Object?> toJson() => _$ObservanceRefToJson(this);
}
