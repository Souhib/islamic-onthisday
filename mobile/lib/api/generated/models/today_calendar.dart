// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'gregorian_date.dart';
import 'hijri_date.dart';

part 'today_calendar.g.dart';

/// Co-primary calendar pair surfaced in the masthead.
@JsonSerializable()
class TodayCalendar {
  const TodayCalendar({
    required this.gregorian,
    required this.hijri,
  });
  
  factory TodayCalendar.fromJson(Map<String, Object?> json) => _$TodayCalendarFromJson(json);
  
  final GregorianDate gregorian;
  final HijriDate hijri;

  Map<String, Object?> toJson() => _$TodayCalendarToJson(this);
}
