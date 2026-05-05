// A small "Save / Saved" toggle that shows on detail pages.
//
// When the user is signed out we route to /sign-in instead of saving —
// the project's stance is that anonymous reading stays the default and
// signing up is purely additive. When signed in, clicking the button
// either saves (if not already saved) or removes the existing bookmark.

import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import type { BookmarkOut } from "@/api/generated/types.gen";
import { useBookmarksQuery, useCreateBookmarkMutation, useDeleteBookmarkMutation } from "@/api/bookmarks";
import { useAuth } from "@/auth/AuthProvider";

interface Props {
  targetKind: "event" | "lesson" | "observance" | "person";
  targetSlug: string;
}

export function SaveButton({ targetKind, targetSlug }: Props) {
  const { t } = useTranslation();
  const { isAuthenticated, isInitialised } = useAuth();
  const bookmarks = useBookmarksQuery({ enabled: isInitialised && isAuthenticated });
  const createMut = useCreateBookmarkMutation();
  const deleteMut = useDeleteBookmarkMutation();

  if (!isInitialised) return null;

  if (!isAuthenticated) {
    return (
      <Link
        to="/sign-in"
        className="inline-flex items-center gap-1.5 border border-rule bg-transparent px-3 py-1.5 font-mono text-[10.5px] uppercase tracking-[1.6px] text-ink-soft hover:border-ink hover:text-ink"
      >
        ♡ {t("auth.save")}
      </Link>
    );
  }

  const existing: BookmarkOut | undefined = bookmarks.data?.items.find(
    (b) => b.targetKind === targetKind && b.targetSlug === targetSlug,
  );

  const handleClick = () => {
    if (existing) {
      deleteMut.mutate(existing.id);
    } else {
      createMut.mutate({ targetKind, targetSlug });
    }
  };

  const busy = createMut.isPending || deleteMut.isPending;

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={busy || bookmarks.isLoading}
      aria-pressed={Boolean(existing)}
      className="inline-flex cursor-pointer items-center gap-1.5 border border-rule bg-transparent px-3 py-1.5 font-mono text-[10.5px] uppercase tracking-[1.6px] text-ink-soft hover:border-ink hover:text-ink disabled:opacity-50"
    >
      {existing ? `♥ ${t("auth.saved")}` : `♡ ${t("auth.save")}`}
    </button>
  );
}
