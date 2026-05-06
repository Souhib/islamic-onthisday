// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_public.g.dart';

/// Public account view — never includes the password hash.
@JsonSerializable()
class UserPublic {
  const UserPublic({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.createdAt,
  });
  
  factory UserPublic.fromJson(Map<String, Object?> json) => _$UserPublicFromJson(json);
  
  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$UserPublicToJson(this);
}
