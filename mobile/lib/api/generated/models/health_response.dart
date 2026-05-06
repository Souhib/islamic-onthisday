// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dataset_snapshot.dart';

part 'health_response.g.dart';

/// Liveness + DB connectivity probe + dataset snapshot.
@JsonSerializable()
class HealthResponse {
  const HealthResponse({
    required this.status,
    required this.database,
    required this.version,
    this.dataset,
  });
  
  factory HealthResponse.fromJson(Map<String, Object?> json) => _$HealthResponseFromJson(json);
  
  final String status;
  final String database;
  final String version;
  final DatasetSnapshot? dataset;

  Map<String, Object?> toJson() => _$HealthResponseToJson(this);
}
