// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/person_detail.dart';

part 'people_client.g.dart';

@RestApi()
abstract class PeopleClient {
  factory PeopleClient(Dio dio, {String? baseUrl}) = _PeopleClient;

  /// Single-person detail by slug.
  ///
  /// Return the full person payload for ``slug``.
  @GET('/api/v1/people/{slug}')
  Future<PersonDetail> getPersonApiV1PeopleSlugGet({
    @Path('slug') required String slug,
  });
}
