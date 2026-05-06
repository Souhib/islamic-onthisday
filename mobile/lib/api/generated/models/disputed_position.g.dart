// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disputed_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisputedPosition _$DisputedPositionFromJson(Map<String, dynamic> json) =>
    DisputedPosition(
      rank: (json['rank'] as num).toInt(),
      value: json['value'] as String,
      scholars: json['scholars'] as String,
      weight: DisputedPositionWeight.fromJson(json['weight'] as String),
    );

Map<String, dynamic> _$DisputedPositionToJson(DisputedPosition instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'value': instance.value,
      'scholars': instance.scholars,
      'weight': _$DisputedPositionWeightEnumMap[instance.weight]!,
    };

const _$DisputedPositionWeightEnumMap = {
  DisputedPositionWeight.primary: 'primary',
  DisputedPositionWeight.notable: 'notable',
  DisputedPositionWeight.minority: 'minority',
  DisputedPositionWeight.$unknown: r'$unknown',
};
