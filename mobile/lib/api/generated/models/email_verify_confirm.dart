// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'email_verify_confirm.g.dart';

/// Inputs for ``POST /api/v1/auth/email/verify``.
@JsonSerializable()
class EmailVerifyConfirm {
  const EmailVerifyConfirm({
    required this.token,
  });
  
  factory EmailVerifyConfirm.fromJson(Map<String, Object?> json) => _$EmailVerifyConfirmFromJson(json);
  
  final String token;

  Map<String, Object?> toJson() => _$EmailVerifyConfirmToJson(this);
}
