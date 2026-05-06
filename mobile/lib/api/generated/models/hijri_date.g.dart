// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_date.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HijriDate _$HijriDateFromJson(Map<String, dynamic> json) => HijriDate(
  day: (json['day'] as num).toInt(),
  month: json['month'] as String,
  monthShort: json['monthShort'] as String,
  year: (json['year'] as num).toInt(),
  weekday: json['weekday'] as String?,
);

Map<String, dynamic> _$HijriDateToJson(HijriDate instance) => <String, dynamic>{
  'day': instance.day,
  'month': instance.month,
  'monthShort': instance.monthShort,
  'year': instance.year,
  'weekday': instance.weekday,
};
