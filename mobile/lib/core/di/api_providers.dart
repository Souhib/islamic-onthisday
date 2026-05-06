import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/iotd_client.dart';
import 'package:iotd_mobile/core/network/dio_client.dart';
import 'package:iotd_mobile/features/auth/auth_provider.dart';

/// Single Dio instance for the lifetime of the app. The generated
/// Retrofit clients all share it via the `IotdClient` aggregator.
/// We pass the secure storage so the auth interceptor can attach a
/// Bearer token on every request and refresh transparently on 401.
final dioProvider = Provider<Dio>((ref) {
  return buildDio(storage: ref.read(secureStorageProvider));
});

/// Root API client — exposes one accessor per resource (today, events,
/// lessons, observances, recent, …). Per-resource providers below give
/// callers a one-liner to grab the client they need without going
/// through this aggregate every time.
final iotdClientProvider = Provider<IotdClient>((ref) {
  return IotdClient(ref.watch(dioProvider));
});
