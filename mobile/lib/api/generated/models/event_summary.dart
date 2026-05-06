// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_summary_dispute_about.dart';
import 'event_summary_verification_status.dart';

part 'event_summary.g.dart';

/// Slim event projection for "On this day" rotation rails — trilingual.
@JsonSerializable()
class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.importance,
    required this.verificationStatus,
    this.disputed = false,
    this.titleAr,
    this.titleFr,
    this.hijri,
    this.gregorian,
    this.era,
    this.disputeAbout,
  });
  
  factory EventSummary.fromJson(Map<String, Object?> json) => _$EventSummaryFromJson(json);
  
  final String id;
  final String title;
  final String? titleAr;
  final String? titleFr;
  final String? hijri;
  final String? gregorian;
  final String? era;
  final String importance;
  final EventSummaryVerificationStatus verificationStatus;
  final bool disputed;
  final EventSummaryDisputeAbout? disputeAbout;

  Map<String, Object?> toJson() => _$EventSummaryToJson(this);
}
