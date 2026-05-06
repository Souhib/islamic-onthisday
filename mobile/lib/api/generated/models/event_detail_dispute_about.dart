// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum EventDetailDisputeAbout {
  @JsonValue('date')
  date('date'),
  @JsonValue('detail')
  detail('detail'),
  @JsonValue('interpretation')
  interpretation('interpretation'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const EventDetailDisputeAbout(this.json);

  factory EventDetailDisputeAbout.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<EventDetailDisputeAbout> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
