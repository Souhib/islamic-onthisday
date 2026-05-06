// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonDetail _$PersonDetailFromJson(Map<String, dynamic> json) => PersonDetail(
  id: json['id'] as String,
  fullNameEn: json['fullNameEn'] as String,
  isProphet: json['isProphet'] as bool? ?? false,
  isSahabi: json['isSahabi'] as bool? ?? false,
  isAhlAlBayt: json['isAhlAlBayt'] as bool? ?? false,
  fullNameAr: json['fullNameAr'] as String?,
  kunya: json['kunya'] as String?,
  laqab: json['laqab'] as String?,
  nisba: json['nisba'] as String?,
  role: json['role'] as String?,
  biography: json['biography'] as String?,
  imageUrl: json['imageUrl'] as String?,
  imageBlockedReason: json['imageBlockedReason'] as String?,
  wikidataQid: json['wikidataQid'] as String?,
);

Map<String, dynamic> _$PersonDetailToJson(PersonDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullNameEn': instance.fullNameEn,
      'fullNameAr': instance.fullNameAr,
      'kunya': instance.kunya,
      'laqab': instance.laqab,
      'nisba': instance.nisba,
      'role': instance.role,
      'biography': instance.biography,
      'isProphet': instance.isProphet,
      'isSahabi': instance.isSahabi,
      'isAhlAlBayt': instance.isAhlAlBayt,
      'imageUrl': instance.imageUrl,
      'imageBlockedReason': instance.imageBlockedReason,
      'wikidataQid': instance.wikidataQid,
    };
