// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/recent_response.dart';

part 'upcoming_client.g.dart';

@RestApi()
abstract class UpcomingClient {
  factory UpcomingClient(Dio dio, {String? baseUrl}) = _UpcomingClient;

  /// Upcoming days — headline + observance for the next N calendar days.
  ///
  /// Return the Upcoming payload — pre-fetch window for daily notifications.
  ///
  /// [days] - How many days to look ahead, starting today.
  @GET('/api/v1/upcoming')
  Future<RecentResponse> getUpcomingApiV1UpcomingGet({
    @Query('days') int? days = 7,
  });
}
