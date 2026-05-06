// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonRef _$PersonRefFromJson(Map<String, dynamic> json) => PersonRef(
  id: json['id'] as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String?,
  nameFr: json['nameFr'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$PersonRefToJson(PersonRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'nameFr': instance.nameFr,
  'role': instance.role,
};
