// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentDay _$RecentDayFromJson(Map<String, dynamic> json) => RecentDay(
  date: json['date'] as String,
  calendar: TodayCalendar.fromJson(json['calendar'] as Map<String, dynamic>),
  headline: json['headline'] == null
      ? null
      : RecentDayHeadlineSealed.fromJson(
          json['headline'] as Map<String, dynamic>,
        ),
  observance: json['observance'] == null
      ? null
      : ObservanceRef.fromJson(json['observance'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecentDayToJson(RecentDay instance) => <String, dynamic>{
  'date': instance.date,
  'calendar': instance.calendar,
  'headline': instance.headline,
  'observance': instance.observance,
};
