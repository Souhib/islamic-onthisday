// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_email_request.g.dart';

/// Inputs for ``POST /api/v1/auth/me/email`` — starts the change flow.
///
/// The password is required as a re-authentication step (the user is.
/// already logged in but we want a fresh proof-of-ownership before.
/// moving the email anywhere). The new email is the destination Resend.
/// sends the verification link to.
@JsonSerializable()
class ChangeEmailRequest {
  const ChangeEmailRequest({
    required this.currentPassword,
    required this.newEmail,
  });
  
  factory ChangeEmailRequest.fromJson(Map<String, Object?> json) => _$ChangeEmailRequestFromJson(json);
  
  final String currentPassword;
  final String newEmail;

  Map<String, Object?> toJson() => _$ChangeEmailRequestToJson(this);
}
