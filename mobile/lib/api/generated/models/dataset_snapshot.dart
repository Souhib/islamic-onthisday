// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'dataset_snapshot.g.dart';

/// Per-resource row counts + dataset freshness signal.
///
/// ``built_at`` and ``age_hours`` come from the most recent ``updated_at``.
/// on the ``events`` table — that's the signal that a pipeline rebuild.
/// actually happened, even when no rows were added or removed.
@JsonSerializable()
class DatasetSnapshot {
  const DatasetSnapshot({
    required this.eventCount,
    required this.lessonCount,
    required this.observanceCount,
    required this.personCount,
    this.builtAt,
    this.ageHours,
  });
  
  factory DatasetSnapshot.fromJson(Map<String, Object?> json) => _$DatasetSnapshotFromJson(json);
  
  final int eventCount;
  final int lessonCount;
  final int observanceCount;
  final int personCount;
  final String? builtAt;
  final num? ageHours;

  Map<String, Object?> toJson() => _$DatasetSnapshotToJson(this);
}
