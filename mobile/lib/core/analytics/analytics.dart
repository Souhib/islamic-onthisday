/// Umami analytics for mobile — privacy-friendly, self-hosted, gated
/// on compile-time env vars.
///
/// Init pattern mirrors ``web/src/lib/analytics.ts``: when both
/// ``UMAMI_URL`` and ``UMAMI_WEBSITE_ID`` are passed via
/// ``--dart-define`` at build time, every helper here POSTs to
/// ``{UMAMI_URL}/api/send``. Without them, every helper is a silent
/// no-op — zero overhead in dev, zero privacy footprint when disabled.
///
/// Event policy (mirrors web):
///   - page_view (auto, on route change) — daily-return rhythm
///   - {event,lesson,observance,person}_view — what people read
///   - language_change — trilingual reach signal
///   - dispute_opened — engagement with editorial dispute model
///
/// Mobile-specific:
///   - bookmark_added — content-affinity signal
///   - auth_sign_up — funnel into accounts
///
/// Every payload includes ``data: {platform: "ios"|"android"}`` so the
/// shared Umami dashboard can split mobile vs. web traffic.
library;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Analytics {
  Analytics._();

  static final Analytics instance = Analytics._();

  static const String _url = String.fromEnvironment('UMAMI_URL');
  static const String _websiteId = String.fromEnvironment('UMAMI_WEBSITE_ID');

  bool get _enabled => _url.isNotEmpty && _websiteId.isNotEmpty;

  /// Stable platform tag — splits mobile vs. web in the Umami dashboard.
  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  /// User-Agent used for every event. Umami infers sessions from
  /// IP + UA, so a consistent UA per install keeps the "unique
  /// visitor" count meaningful.
  String get _userAgent => 'Thaqafa-Mobile/$_platform';

  late final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': _userAgent,
    },
  ));

  /// Send a payload to Umami's /api/send endpoint. Fire-and-forget:
  /// errors are swallowed so analytics never crashes the UX.
  void _send({
    required String path,
    String? title,
    String? eventName,
    Map<String, dynamic>? eventData,
    String? language,
  }) {
    if (!_enabled) return;
    final payload = <String, dynamic>{
      'website': _websiteId,
      'hostname': 'thaqafa.app',
      'url': path,
      'language': language ?? '',
      'screen': '',
      'referrer': '',
      'title': ?title,
      'name': ?eventName,
      'data': {
        ...?eventData,
        'platform': _platform,
      },
    };
    unawaited(
      _dio
          .post<void>('$_url/api/send', data: {
        'type': 'event',
        'payload': payload,
      })
          .catchError((_) {
        // Silent: analytics never propagates failure.
        return Response<void>(requestOptions: RequestOptions());
      }),
    );
  }

  // ---------------------------------------------------------------------
  // Page views — call on every route change.
  // ---------------------------------------------------------------------

  /// Record a page view at ``path``. Called from the router observer
  /// after every navigation.
  void trackPageView(String path, {String? title, String? language}) =>
      _send(path: path, title: title, language: language);

  // ---------------------------------------------------------------------
  // Domain-specific helpers. Exhaustively named so an IDE autocompletes
  // the full menu of trackable signals.
  // ---------------------------------------------------------------------

  /// User opened an event detail page.
  void trackEventView(String slug, {String? language}) => _send(
        path: '/event/$slug',
        eventName: 'event_view',
        eventData: {'slug': slug},
        language: language,
      );

  /// User opened a lesson detail page.
  void trackLessonView(String slug, {String? language}) => _send(
        path: '/lesson/$slug',
        eventName: 'lesson_view',
        eventData: {'slug': slug},
        language: language,
      );

  /// User opened an observance detail page.
  void trackObservanceView(String slug, {String? language}) => _send(
        path: '/observance/$slug',
        eventName: 'observance_view',
        eventData: {'slug': slug},
        language: language,
      );

  /// User opened a person profile page.
  void trackPersonView(String slug, {String? language}) => _send(
        path: '/person/$slug',
        eventName: 'person_view',
        eventData: {'slug': slug},
        language: language,
      );

  /// User switched UI language. Real trilingual-reach signal.
  void trackLanguageChange(String language) => _send(
        path: '/settings',
        eventName: 'language_change',
        eventData: {'language': language},
        language: language,
      );

  /// User opened the disputed-views drawer.
  void trackDisputeOpened(String slug, {String? language}) => _send(
        path: '/event/$slug',
        eventName: 'dispute_opened',
        eventData: {'slug': slug},
        language: language,
      );

  /// User saved a bookmark. ``kind`` is one of event/lesson/observance/person.
  void trackBookmarkAdded(String kind, String slug, {String? language}) =>
      _send(
        path: '/bookmark',
        eventName: 'bookmark_added',
        eventData: {'kind': kind, 'slug': slug},
        language: language,
      );

  /// User completed sign-up. Funnel signal — paired with sign_in to see
  /// account creation vs. returning login.
  void trackSignUp({String? language}) => _send(
        path: '/sign-up',
        eventName: 'auth_sign_up',
        language: language,
      );

  /// User signed in to an existing account.
  void trackSignIn({String? language}) => _send(
        path: '/sign-in',
        eventName: 'auth_sign_in',
        language: language,
      );
}
