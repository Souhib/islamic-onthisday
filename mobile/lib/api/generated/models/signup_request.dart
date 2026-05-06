// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'signup_request.g.dart';

/// Inputs for ``POST /api/v1/auth/signup``.
///
/// ``display_name`` is required at the API boundary so every new account.
/// has a human label for the saves header (the ``User`` row keeps the.
/// column nullable so legacy / admin-created rows aren't forced to.
/// backfill).
@JsonSerializable()
class SignupRequest {
  const SignupRequest({
    required this.email,
    required this.password,
    required this.displayName,
  });
  
  factory SignupRequest.fromJson(Map<String, Object?> json) => _$SignupRequestFromJson(json);
  
  final String email;
  final String password;
  final String displayName;

  Map<String, Object?> toJson() => _$SignupRequestToJson(this);
}
