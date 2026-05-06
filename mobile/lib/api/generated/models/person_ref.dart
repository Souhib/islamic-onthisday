// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'person_ref.g.dart';

/// A person attached to an event.
@JsonSerializable()
class PersonRef {
  const PersonRef({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameFr,
    this.role,
  });
  
  factory PersonRef.fromJson(Map<String, Object?> json) => _$PersonRefFromJson(json);
  
  final String id;
  final String name;
  final String? nameAr;
  final String? nameFr;
  final String? role;

  Map<String, Object?> toJson() => _$PersonRefToJson(this);
}
