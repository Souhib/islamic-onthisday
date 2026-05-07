import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/bookmark_create.dart';
import 'package:thaqafa/api/generated/models/bookmark_create_target_kind.dart';
import 'package:thaqafa/api/generated/models/bookmark_list.dart';
import 'package:thaqafa/api/generated/models/bookmark_out.dart';
import 'package:thaqafa/core/di/api_providers.dart';

/// AsyncNotifier holding the user's bookmark list. Tap-to-bookmark
/// performs an optimistic update so the SaveButton is responsive
/// even on a slow connection; rollback on error.
class BookmarksNotifier extends AsyncNotifier<List<BookmarkOut>> {
  @override
  Future<List<BookmarkOut>> build() async {
    final client = ref.watch(thaqafaClientProvider).bookmarks;
    final BookmarkList list = await client.listBookmarksApiV1BookmarksGet();
    return list.items;
  }

  bool isBookmarked(String slug) {
    final s = state.value;
    if (s == null) return false;
    return s.any((b) => b.targetSlug == slug);
  }

  Future<void> add({
    required String slug,
    required BookmarkCreateTargetKind kind,
  }) async {
    final client = ref.read(thaqafaClientProvider).bookmarks;
    final created = await client.createBookmarkApiV1BookmarksPost(
      body: BookmarkCreate(targetKind: kind, targetSlug: slug, note: null),
    );
    state = AsyncValue.data([...?state.value, created]);
  }

  Future<void> remove(String slug) async {
    final s = state.value;
    if (s == null) return;
    final match = s.where((b) => b.targetSlug == slug).firstOrNull;
    if (match == null) return;
    final client = ref.read(thaqafaClientProvider).bookmarks;
    state = AsyncValue.data(s.where((b) => b.id != match.id).toList());
    await client.deleteBookmarkApiV1BookmarksBookmarkIdDelete(bookmarkId: match.id);
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<BookmarkOut>>(
  BookmarksNotifier.new,
);
