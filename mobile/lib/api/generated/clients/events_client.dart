// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event_detail.dart';

part 'events_client.g.dart';

@RestApi()
abstract class EventsClient {
  factory EventsClient(Dio dio, {String? baseUrl}) = _EventsClient;

  /// Single-event detail by slug.
  ///
  /// Return the full event payload for ``slug``.
  @GET('/api/v1/events/{slug}')
  Future<EventDetail> getEventApiV1EventsSlugGet({
    @Path('slug') required String slug,
  });
}
