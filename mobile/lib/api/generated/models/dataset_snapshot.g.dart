// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatasetSnapshot _$DatasetSnapshotFromJson(Map<String, dynamic> json) =>
    DatasetSnapshot(
      eventCount: (json['eventCount'] as num).toInt(),
      lessonCount: (json['lessonCount'] as num).toInt(),
      observanceCount: (json['observanceCount'] as num).toInt(),
      personCount: (json['personCount'] as num).toInt(),
      builtAt: json['builtAt'] as String?,
      ageHours: json['ageHours'] as num?,
    );

Map<String, dynamic> _$DatasetSnapshotToJson(DatasetSnapshot instance) =>
    <String, dynamic>{
      'eventCount': instance.eventCount,
      'lessonCount': instance.lessonCount,
      'observanceCount': instance.observanceCount,
      'personCount': instance.personCount,
      'builtAt': instance.builtAt,
      'ageHours': instance.ageHours,
    };
