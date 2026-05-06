// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_display_name_request.g.dart';

/// Inputs for ``PATCH /api/v1/auth/me``.
@JsonSerializable()
class ChangeDisplayNameRequest {
  const ChangeDisplayNameRequest({
    required this.displayName,
  });
  
  factory ChangeDisplayNameRequest.fromJson(Map<String, Object?> json) => _$ChangeDisplayNameRequestFromJson(json);
  
  final String displayName;

  Map<String, Object?> toJson() => _$ChangeDisplayNameRequestToJson(this);
}
