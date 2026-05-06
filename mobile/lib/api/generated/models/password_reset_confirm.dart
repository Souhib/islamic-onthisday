// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'password_reset_confirm.g.dart';

/// Inputs for ``POST /api/v1/auth/password-reset/confirm``.
@JsonSerializable()
class PasswordResetConfirm {
  const PasswordResetConfirm({
    required this.token,
    required this.newPassword,
  });
  
  factory PasswordResetConfirm.fromJson(Map<String, Object?> json) => _$PasswordResetConfirmFromJson(json);
  
  final String token;
  final String newPassword;

  Map<String, Object?> toJson() => _$PasswordResetConfirmToJson(this);
}
