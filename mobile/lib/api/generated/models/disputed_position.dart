// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'disputed_position_weight.dart';

part 'disputed_position.g.dart';

/// One scholarly position on a disputed date or fact.
///
/// ``weight`` is a discriminant (``primary | notable | minority``) — the.
/// front-end maps it to a localised label.
@JsonSerializable()
class DisputedPosition {
  const DisputedPosition({
    required this.rank,
    required this.value,
    required this.scholars,
    required this.weight,
  });
  
  factory DisputedPosition.fromJson(Map<String, Object?> json) => _$DisputedPositionFromJson(json);
  
  final int rank;
  final String value;
  final String scholars;
  final DisputedPositionWeight weight;

  Map<String, Object?> toJson() => _$DisputedPositionToJson(this);
}
