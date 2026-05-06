// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_email_confirm.g.dart';

/// Inputs for ``POST /api/v1/auth/me/email/confirm`` — completes the flow.
@JsonSerializable()
class ChangeEmailConfirm {
  const ChangeEmailConfirm({
    required this.token,
  });
  
  factory ChangeEmailConfirm.fromJson(Map<String, Object?> json) => _$ChangeEmailConfirmFromJson(json);
  
  final String token;

  Map<String, Object?> toJson() => _$ChangeEmailConfirmToJson(this);
}
