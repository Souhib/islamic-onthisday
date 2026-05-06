// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum EventSummaryVerificationStatus {
  @JsonValue('scholar_reviewed')
  scholarReviewed('scholar_reviewed'),
  @JsonValue('cross_verified')
  crossVerified('cross_verified'),
  @JsonValue('single_source')
  singleSource('single_source'),
  @JsonValue('unverified')
  unverified('unverified'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const EventSummaryVerificationStatus(this.json);

  factory EventSummaryVerificationStatus.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<EventSummaryVerificationStatus> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
