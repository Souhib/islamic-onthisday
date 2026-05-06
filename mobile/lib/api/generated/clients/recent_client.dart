// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/recent_response.dart';

part 'recent_client.g.dart';

@RestApi()
abstract class RecentClient {
  factory RecentClient(Dio dio, {String? baseUrl}) = _RecentClient;

  /// Recent days — headline and observance for the last 7 calendar days.
  ///
  /// Return the Recent payload — the catch-up window.
  @GET('/api/v1/recent')
  Future<RecentResponse> getRecentApiV1RecentGet();
}
