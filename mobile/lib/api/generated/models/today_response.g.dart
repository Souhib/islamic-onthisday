// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayResponse _$TodayResponseFromJson(Map<String, dynamic> json) =>
    TodayResponse(
      today: TodayCalendar.fromJson(json['today'] as Map<String, dynamic>),
      secondary:
          (json['secondary'] as List<dynamic>?)
              ?.map(
                (e) => TodayResponseSecondarySealed.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      headline: json['headline'] == null
          ? null
          : TodayResponseHeadlineSealed.fromJson(
              json['headline'] as Map<String, dynamic>,
            ),
      observance: json['observance'] == null
          ? null
          : ObservanceRef.fromJson(json['observance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TodayResponseToJson(TodayResponse instance) =>
    <String, dynamic>{
      'today': instance.today,
      'headline': instance.headline,
      'secondary': instance.secondary,
      'observance': instance.observance,
    };
