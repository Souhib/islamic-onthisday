// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gregorian_date.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GregorianDate _$GregorianDateFromJson(Map<String, dynamic> json) =>
    GregorianDate(
      day: (json['day'] as num).toInt(),
      month: json['month'] as String,
      year: (json['year'] as num).toInt(),
      weekday: json['weekday'] as String,
    );

Map<String, dynamic> _$GregorianDateToJson(GregorianDate instance) =>
    <String, dynamic>{
      'day': instance.day,
      'month': instance.month,
      'year': instance.year,
      'weekday': instance.weekday,
    };
