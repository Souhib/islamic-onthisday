// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'observance_ref.dart';
import 'recent_day_headline_sealed.dart';
import 'today_calendar.dart';

part 'recent_day.g.dart';

/// One day inside the ``/api/v1/recent`` response.
@JsonSerializable()
class RecentDay {
  const RecentDay({
    required this.date,
    required this.calendar,
    this.headline,
    this.observance,
  });
  
  factory RecentDay.fromJson(Map<String, Object?> json) => _$RecentDayFromJson(json);
  
  final String date;
  final TodayCalendar calendar;
  final RecentDayHeadlineSealed? headline;
  final ObservanceRef? observance;

  Map<String, Object?> toJson() => _$RecentDayToJson(this);
}
