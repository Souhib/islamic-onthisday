// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/today_response.dart';

part 'today_client.g.dart';

@RestApi()
abstract class TodayClient {
  factory TodayClient(Dio dio, {String? baseUrl}) = _TodayClient;

  /// Headline event, secondary rails, observance for the current day.
  ///
  /// Return the Today payload for the current UTC day.
  ///
  /// A CDN can serve the same payload to thousands of readers in the same.
  /// time zone with one origin hit; the dependency stamps a Cache-Control.
  /// that expires at the next UTC midnight so the rollover is automatic.
  @GET('/api/v1/today')
  Future<TodayResponse> getTodayApiV1TodayGet();
}
