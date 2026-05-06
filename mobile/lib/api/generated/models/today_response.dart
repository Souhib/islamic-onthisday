// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'observance_ref.dart';
import 'today_calendar.dart';
import 'today_response_headline_sealed.dart';
import 'today_response_secondary_sealed.dart';

part 'today_response.g.dart';

/// The full ``/api/v1/today`` payload.
@JsonSerializable()
class TodayResponse {
  const TodayResponse({
    required this.today,
    this.secondary = const [],
    this.headline,
    this.observance,
  });
  
  factory TodayResponse.fromJson(Map<String, Object?> json) => _$TodayResponseFromJson(json);
  
  final TodayCalendar today;
  final TodayResponseHeadlineSealed? headline;
  final List<TodayResponseSecondarySealed> secondary;
  final ObservanceRef? observance;

  Map<String, Object?> toJson() => _$TodayResponseToJson(this);
}
