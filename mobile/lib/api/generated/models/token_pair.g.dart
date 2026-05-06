// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => TokenPair(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accessExpiresAt: DateTime.parse(json['accessExpiresAt'] as String),
  refreshExpiresAt: DateTime.parse(json['refreshExpiresAt'] as String),
  user: UserPublic.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'accessExpiresAt': instance.accessExpiresAt.toIso8601String(),
  'refreshExpiresAt': instance.refreshExpiresAt.toIso8601String(),
  'user': instance.user,
};
