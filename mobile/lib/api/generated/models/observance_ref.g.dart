// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observance_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObservanceRef _$ObservanceRefFromJson(Map<String, dynamic> json) =>
    ObservanceRef(
      id: json['id'] as String,
      name: json['name'] as String,
      hijriDate: json['hijriDate'] as String,
      nameAr: json['nameAr'] as String?,
      nameFr: json['nameFr'] as String?,
      summary: json['summary'] as String?,
      summaryAr: json['summaryAr'] as String?,
      summaryFr: json['summaryFr'] as String?,
    );

Map<String, dynamic> _$ObservanceRefToJson(ObservanceRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'nameFr': instance.nameFr,
      'hijriDate': instance.hijriDate,
      'summary': instance.summary,
      'summaryAr': instance.summaryAr,
      'summaryFr': instance.summaryFr,
    };
