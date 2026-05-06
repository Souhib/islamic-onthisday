import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iotd_mobile/core/config/api_config.dart';

/// Builds the singleton Dio instance the generated Retrofit clients
/// hang off. Configures base URL, timeouts, default headers and a
/// minimal logging interceptor in debug — auth + retry interceptors
/// will land alongside the auth feature in phase 5.
Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'iotd-mobile/0.1.0 (debug)',
      },
      responseType: ResponseType.json,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestHeader: true,
        requestBody: false,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (Object o) => debugPrint('[dio] $o'),
      ),
    );
  }

  return dio;
}
