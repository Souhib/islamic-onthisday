// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'recent_day.dart';

part 'recent_response.g.dart';

/// The full ``/api/v1/recent`` payload.
@JsonSerializable()
class RecentResponse {
  const RecentResponse({
    required this.days,
  });
  
  factory RecentResponse.fromJson(Map<String, Object?> json) => _$RecentResponseFromJson(json);
  
  final List<RecentDay> days;

  Map<String, Object?> toJson() => _$RecentResponseToJson(this);
}
