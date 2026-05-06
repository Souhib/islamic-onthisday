// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayCalendar _$TodayCalendarFromJson(Map<String, dynamic> json) =>
    TodayCalendar(
      gregorian: GregorianDate.fromJson(
        json['gregorian'] as Map<String, dynamic>,
      ),
      hijri: HijriDate.fromJson(json['hijri'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TodayCalendarToJson(TodayCalendar instance) =>
    <String, dynamic>{'gregorian': instance.gregorian, 'hijri': instance.hijri};
