// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'hijri_date.g.dart';

/// Calendar slot — Hijri side.
@JsonSerializable()
class HijriDate {
  const HijriDate({
    required this.day,
    required this.month,
    required this.monthShort,
    required this.year,
    this.weekday,
  });
  
  factory HijriDate.fromJson(Map<String, Object?> json) => _$HijriDateFromJson(json);
  
  final int day;
  final String month;
  final String monthShort;
  final int year;
  final String? weekday;

  Map<String, Object?> toJson() => _$HijriDateToJson(this);
}
