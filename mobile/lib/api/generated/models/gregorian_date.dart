// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'gregorian_date.g.dart';

/// Calendar slot — Gregorian side.
@JsonSerializable()
class GregorianDate {
  const GregorianDate({
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
  });
  
  factory GregorianDate.fromJson(Map<String, Object?> json) => _$GregorianDateFromJson(json);
  
  final int day;
  final String month;
  final int year;
  final String weekday;

  Map<String, Object?> toJson() => _$GregorianDateToJson(this);
}
