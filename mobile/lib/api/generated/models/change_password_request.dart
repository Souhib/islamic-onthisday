// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_password_request.g.dart';

/// Inputs for ``POST /api/v1/auth/me/password``.
@JsonSerializable()
class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });
  
  factory ChangePasswordRequest.fromJson(Map<String, Object?> json) => _$ChangePasswordRequestFromJson(json);
  
  final String currentPassword;
  final String newPassword;

  Map<String, Object?> toJson() => _$ChangePasswordRequestToJson(this);
}
