// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentResponse _$RecentResponseFromJson(Map<String, dynamic> json) =>
    RecentResponse(
      days: (json['days'] as List<dynamic>)
          .map((e) => RecentDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecentResponseToJson(RecentResponse instance) =>
    <String, dynamic>{'days': instance.days};
