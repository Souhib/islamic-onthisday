// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceRef _$SourceRefFromJson(Map<String, dynamic> json) => SourceRef(
  label: json['label'] as String,
  kind: SourceRefKind.fromJson(json['kind'] as String),
  verify: json['verify'] as String?,
);

Map<String, dynamic> _$SourceRefToJson(SourceRef instance) => <String, dynamic>{
  'label': instance.label,
  'kind': _$SourceRefKindEnumMap[instance.kind]!,
  'verify': instance.verify,
};

const _$SourceRefKindEnumMap = {
  SourceRefKind.classical: 'classical',
  SourceRefKind.primary: 'primary',
  SourceRefKind.modern: 'modern',
  SourceRefKind.$unknown: r'$unknown',
};
