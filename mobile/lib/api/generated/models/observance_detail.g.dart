// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observance_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObservanceDetail _$ObservanceDetailFromJson(Map<String, dynamic> json) =>
    ObservanceDetail(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      descriptionEn: json['descriptionEn'] as String,
      hijriMonth: (json['hijriMonth'] as num).toInt(),
      importance: json['importance'] as String,
      windowDays: (json['windowDays'] as num?)?.toInt() ?? 1,
      nameAr: json['nameAr'] as String?,
      nameFr: json['nameFr'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionFr: json['descriptionFr'] as String?,
      hijriDay: (json['hijriDay'] as num?)?.toInt(),
      quranRefs: json['quranRefs'] as String?,
      hadithRefs: json['hadithRefs'] as String?,
    );

Map<String, dynamic> _$ObservanceDetailToJson(ObservanceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'nameFr': instance.nameFr,
      'descriptionEn': instance.descriptionEn,
      'descriptionAr': instance.descriptionAr,
      'descriptionFr': instance.descriptionFr,
      'hijriMonth': instance.hijriMonth,
      'hijriDay': instance.hijriDay,
      'windowDays': instance.windowDays,
      'importance': instance.importance,
      'quranRefs': instance.quranRefs,
      'hadithRefs': instance.hadithRefs,
    };
