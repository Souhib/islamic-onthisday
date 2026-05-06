// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'disputed_position.dart';
import 'event_detail_dispute_about.dart';
import 'event_detail_verification_status.dart';
import 'person_ref.dart';
import 'source_ref.dart';

part 'event_detail.g.dart';

/// Full event projection used by the headline + event-detail surfaces.
///
/// Trilingual: ``title`` (English) + ``title_ar`` (Arabic) + ``title_fr``.
/// (French) all surfaced; ``summary`` and ``body`` likewise. Front-end.
/// chooses which to render.
@JsonSerializable()
class EventDetail {
  const EventDetail({
    required this.id,
    required this.title,
    required this.importance,
    required this.verificationStatus,
    required this.summary,
    this.noImage = false,
    this.body = const [],
    this.bodyAr = const [],
    this.bodyFr = const [],
    this.people = const [],
    this.sources = const [],
    this.disputed = false,
    this.disputedPositions = const [],
    this.titleAr,
    this.titleFr,
    this.era,
    this.gregorian,
    this.hijri,
    this.location,
    this.placeholder,
    this.imageUrl,
    this.summaryAr,
    this.summaryFr,
    this.disputeAbout,
    this.sourceUrl,
    this.quranRefs,
  });
  
  factory EventDetail.fromJson(Map<String, Object?> json) => _$EventDetailFromJson(json);
  
  final String id;
  final String title;
  final String? titleAr;
  final String? titleFr;
  final String? era;
  final String importance;
  final EventDetailVerificationStatus verificationStatus;
  final String? gregorian;
  final String? hijri;
  final String? location;
  final String? placeholder;
  final bool noImage;
  final String? imageUrl;
  final String summary;
  final String? summaryAr;
  final String? summaryFr;
  final List<String> body;
  final List<String> bodyAr;
  final List<String> bodyFr;
  final List<PersonRef> people;
  final List<SourceRef> sources;
  final bool disputed;
  final EventDetailDisputeAbout? disputeAbout;
  final List<DisputedPosition> disputedPositions;
  final String? sourceUrl;
  final String? quranRefs;

  Map<String, Object?> toJson() => _$EventDetailToJson(this);
}
