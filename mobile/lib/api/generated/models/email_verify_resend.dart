// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'email_verify_resend.g.dart';

/// Inputs for ``POST /api/v1/auth/email/resend``.
@JsonSerializable()
class EmailVerifyResend {
  const EmailVerifyResend({
    required this.email,
  });
  
  factory EmailVerifyResend.fromJson(Map<String, Object?> json) => _$EmailVerifyResendFromJson(json);
  
  final String email;

  Map<String, Object?> toJson() => _$EmailVerifyResendToJson(this);
}
