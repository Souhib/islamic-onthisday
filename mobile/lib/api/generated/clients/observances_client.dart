// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/observance_detail.dart';

part 'observances_client.g.dart';

@RestApi()
abstract class ObservancesClient {
  factory ObservancesClient(Dio dio, {String? baseUrl}) = _ObservancesClient;

  /// List every recurring annual observance.
  ///
  /// Return every observance, ordered by Hijri month + day.
  @GET('/api/v1/observances')
  Future<List<ObservanceDetail>> listObservancesApiV1ObservancesGet();

  /// Single observance by slug.
  ///
  /// Look up one observance.
  @GET('/api/v1/observances/{slug}')
  Future<ObservanceDetail> getObservanceApiV1ObservancesSlugGet({
    @Path('slug') required String slug,
  });
}
