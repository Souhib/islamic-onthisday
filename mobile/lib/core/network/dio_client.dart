import 'package:dio/dio.dart';
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
Dio buildDio({SecureStorageService? storage}) {
  final dio = Dio(_baseOptions());

  if (storage != null) {
    final refreshDio = Dio(_baseOptions());
    dio.interceptors.add(
      AuthInterceptor(storage: storage, refreshDio: refreshDio),
    );
  }

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
