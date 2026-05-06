// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/system_client.dart';
import 'clients/today_client.dart';
import 'clients/events_client.dart';
import 'clients/lessons_client.dart';
import 'clients/observances_client.dart';
import 'clients/people_client.dart';
import 'clients/recent_client.dart';
import 'clients/upcoming_client.dart';
import 'clients/auth_client.dart';
import 'clients/bookmarks_client.dart';

/// Islamic On This Day `v0.1.0`.
///
/// Read-only API serving one verified Islamic-history event per day, in both Hijri and Gregorian calendars. Backed by the data-pipeline's curated SQLite database.
class IotdClient {
  IotdClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  SystemClient? _system;
  TodayClient? _today;
  EventsClient? _events;
  LessonsClient? _lessons;
  ObservancesClient? _observances;
  PeopleClient? _people;
  RecentClient? _recent;
  UpcomingClient? _upcoming;
  AuthClient? _auth;
  BookmarksClient? _bookmarks;

  SystemClient get system => _system ??= SystemClient(_dio, baseUrl: _baseUrl);

  TodayClient get today => _today ??= TodayClient(_dio, baseUrl: _baseUrl);

  EventsClient get events => _events ??= EventsClient(_dio, baseUrl: _baseUrl);

  LessonsClient get lessons => _lessons ??= LessonsClient(_dio, baseUrl: _baseUrl);

  ObservancesClient get observances => _observances ??= ObservancesClient(_dio, baseUrl: _baseUrl);

  PeopleClient get people => _people ??= PeopleClient(_dio, baseUrl: _baseUrl);

  RecentClient get recent => _recent ??= RecentClient(_dio, baseUrl: _baseUrl);

  UpcomingClient get upcoming => _upcoming ??= UpcomingClient(_dio, baseUrl: _baseUrl);

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  BookmarksClient get bookmarks => _bookmarks ??= BookmarksClient(_dio, baseUrl: _baseUrl);
}
