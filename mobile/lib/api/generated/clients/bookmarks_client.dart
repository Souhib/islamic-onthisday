// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/bookmark_create.dart';
import '../models/bookmark_list.dart';
import '../models/bookmark_out.dart';

part 'bookmarks_client.g.dart';

@RestApi()
abstract class BookmarksClient {
  factory BookmarksClient(Dio dio, {String? baseUrl}) = _BookmarksClient;

  /// List the authenticated user's saved items
  @GET('/api/v1/bookmarks')
  Future<BookmarkList> listBookmarksApiV1BookmarksGet({
    @Header('Authorization') String? authorization,
    @Query('limit') int? limit = 100,
    @Query('offset') int? offset = 0,
  });

  /// Save a new bookmark
  @POST('/api/v1/bookmarks')
  Future<BookmarkOut> createBookmarkApiV1BookmarksPost({
    @Body() required BookmarkCreate body,
    @Header('Authorization') String? authorization,
  });

  /// Delete one of the authenticated user's bookmarks
  @DELETE('/api/v1/bookmarks/{bookmark_id}')
  Future<void> deleteBookmarkApiV1BookmarksBookmarkIdDelete({
    @Path('bookmark_id') required String bookmarkId,
    @Header('Authorization') String? authorization,
  });
}
