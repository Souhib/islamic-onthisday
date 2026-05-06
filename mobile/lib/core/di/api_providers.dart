import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/iotd_client.dart';
import 'package:iotd_mobile/core/network/dio_client.dart';

/// Single Dio instance for the lifetime of the app. The generated
/// Retrofit clients all share it via the `IotdClient` aggregator.
final dioProvider = Provider<Dio>((ref) => buildDio());

/// Root API client — exposes one accessor per resource (today, events,
/// lessons, observances, recent, …). Per-resource providers below give
/// callers a one-liner to grab the client they need without going
/// through this aggregate every time.
final iotdClientProvider = Provider<IotdClient>((ref) {
  return IotdClient(ref.watch(dioProvider));
});
