import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:iotd_mobile/core/config/api_config.dart';
import 'package:iotd_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:iotd_mobile/core/storage/secure_storage_service.dart';

/// Builds a Dio instance configured for the app.
///
/// When `storage` is provided we layer the auth interceptor (Bearer
/// token + transparent refresh on 401). The refresh endpoint goes
/// through a *separate* bare Dio instance — same baseUrl + timeouts,
/// no interceptors — to avoid recursion if the refresh response 401s.
///
/// A short-lived in-memory HTTP cache sits in front of every
/// successful GET (`Today`, `Recent`, `Observances`, detail
/// payloads). Cold-start from background re-renders instantly with
/// the cached body; the network call still fires in the background
/// and rebuilds the UI when fresher data lands.
Dio buildDio({SecureStorageService? storage}) {
  final dio = Dio(_baseOptions());

  if (storage != null) {
    final refreshDio = Dio(_baseOptions());
    dio.interceptors.add(
      AuthInterceptor(storage: storage, refreshDio: refreshDio),
    );
  }

  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(maxSize: 4 * 1024 * 1024, maxEntrySize: 512 * 1024),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorCodes: [401, 403, 500, 502, 503, 504],
        hitCacheOnNetworkFailure: true,
        maxStale: const Duration(hours: 12),
        priority: CachePriority.normal,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      ),
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (Object o) => debugPrint('[dio] $o'),
      ),
    );
  }

  return dio;
}

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'iotd-mobile/0.1.0',
      },
      responseType: ResponseType.json,
    );
