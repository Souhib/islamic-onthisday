// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetConfirm _$PasswordResetConfirmFromJson(
  Map<String, dynamic> json,
) => PasswordResetConfirm(
  token: json['token'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmToJson(
  PasswordResetConfirm instance,
) => <String, dynamic>{
  'token': instance.token,
  'newPassword': instance.newPassword,
};
