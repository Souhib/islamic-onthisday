// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      database: json['database'] as String,
      version: json['version'] as String,
      dataset: json['dataset'] == null
          ? null
          : DatasetSnapshot.fromJson(json['dataset'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'database': instance.database,
      'version': instance.version,
      'dataset': instance.dataset,
    };
