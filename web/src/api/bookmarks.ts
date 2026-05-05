// TanStack Query hooks for the bookmarks endpoints.
//
// All three endpoints are gated behind the `Authorization: Bearer …` header
// stamped by the AuthProvider's request interceptor. The hooks themselves
// are agnostic — they don't read auth state, they just refuse to fire when
// `enabled` is false (callers pass `enabled: isAuthenticated`).

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createBookmarkApiV1BookmarksPost,
  deleteBookmarkApiV1BookmarksBookmarkIdDelete,
  listBookmarksApiV1BookmarksGet,
} from "@/api/generated/sdk.gen";
import type { BookmarkCreate, BookmarkList } from "@/api/generated/types.gen";

const BOOKMARKS_QUERY_KEY = ["bookmarks"] as const;

export function useBookmarksQuery(options: { enabled?: boolean } = {}) {
  return useQuery<BookmarkList>({
    queryKey: BOOKMARKS_QUERY_KEY,
    queryFn: async () => {
      const res = await listBookmarksApiV1BookmarksGet();
      if (!res.data) throw new Error("bookmarks fetch returned empty data");
      return res.data;
    },
    enabled: options.enabled ?? true,
  });
}

export function useCreateBookmarkMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: BookmarkCreate) => {
      const res = await createBookmarkApiV1BookmarksPost({ body });
      if (!res.data) throw new Error("bookmark create returned empty data");
      return res.data;
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: BOOKMARKS_QUERY_KEY }),
  });
}

export function useDeleteBookmarkMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (bookmarkId: string) => {
      await deleteBookmarkApiV1BookmarksBookmarkIdDelete({ path: { bookmark_id: bookmarkId } });
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: BOOKMARKS_QUERY_KEY }),
  });
}
