// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeEmailRequest _$ChangeEmailRequestFromJson(Map<String, dynamic> json) =>
    ChangeEmailRequest(
      currentPassword: json['currentPassword'] as String,
      newEmail: json['newEmail'] as String,
    );

Map<String, dynamic> _$ChangeEmailRequestToJson(ChangeEmailRequest instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newEmail': instance.newEmail,
    };
