// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'source_ref_kind.dart';

part 'source_ref.g.dart';

/// A citable source attached to an event.
@JsonSerializable()
class SourceRef {
  const SourceRef({
    required this.label,
    required this.kind,
    this.verify,
  });
  
  factory SourceRef.fromJson(Map<String, Object?> json) => _$SourceRefFromJson(json);
  
  final String label;
  final SourceRefKind kind;
  final String? verify;

  Map<String, Object?> toJson() => _$SourceRefToJson(this);
}
