import 'package:dio/dio.dart';
import 'package:iotd_mobile/api/generated/models/refresh_request.dart';
import 'package:iotd_mobile/core/storage/secure_storage_service.dart';

/// Attaches the bearer token to outbound requests when present, and
/// transparently retries with a refresh on 401. If refresh itself
/// fails, the tokens are wiped — the auth notifier will catch the
/// resulting state on its next read.
///
/// The refresh endpoint is invoked through a *separate* Dio instance
/// (no interceptor) to avoid recursion when the refresh response
/// itself fails authentication.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, required this.refreshDio});

  final SecureStorageService storage;
  final Dio refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/signup') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }
    final access = await storage.readAccess();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    final refresh = await storage.readRefresh();
    if (refresh == null) {
      await storage.clear();
      handler.next(err);
      return;
    }

    try {
      final response = await refreshDio.post<Map<String, Object?>>(
        '/api/v1/auth/refresh',
        data: RefreshRequest(refreshToken: refresh).toJson(),
      );
      final body = response.data!;
      final newAccess = body['access_token'] as String;
      final newRefresh = body['refresh_token'] as String;
      final accessExp = DateTime.parse(body['access_expires_at'] as String);
      final refreshExp = DateTime.parse(body['refresh_expires_at'] as String);
      await storage.writeTokens(
        access: newAccess,
        refresh: newRefresh,
        accessExpiresAt: accessExp,
        refreshExpiresAt: refreshExp,
      );

      final retry = await refreshDio.fetch<Map<String, Object?>>(
        err.requestOptions.copyWith(
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $newAccess',
          },
        ),
      );
      handler.resolve(retry);
    } on DioException {
      await storage.clear();
      handler.next(err);
    }
  }
}
