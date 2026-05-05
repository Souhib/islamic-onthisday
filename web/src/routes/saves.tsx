import { Link, createFileRoute, redirect } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useBookmarksQuery, useDeleteBookmarkMutation } from "@/api/bookmarks";
import type { BookmarkOut } from "@/api/generated/types.gen";
import { useAuth } from "@/auth/AuthProvider";
import { PageShell } from "@/components/reader/PageShell";
import { Loading } from "@/components/ui/Loading";
import { type Language, pickLocalised, useLanguage } from "@/providers/LanguageProvider";

function targetTitle(b: BookmarkOut, lang: Language): string {
  return (
    pickLocalised(
      { en: b.targetTitle ?? null, fr: b.targetTitleFr ?? null, ar: b.targetTitleAr ?? null },
      lang,
    ) ?? b.targetSlug
  );
}

function detailHref(b: BookmarkOut): string {
  switch (b.targetKind) {
    case "event":
      return `/events/${b.targetSlug}`;
    case "lesson":
      return `/lessons/${b.targetSlug}`;
    case "observance":
      return `/observances/${b.targetSlug}`;
    case "person":
      return `/people/${b.targetSlug}`;
  }
}

function SavesPage() {
  const { t } = useTranslation();
  const { lang } = useLanguage();
  const { user, logout } = useAuth();
  const { data, isLoading } = useBookmarksQuery();
  const deleteMut = useDeleteBookmarkMutation();
  const [filter, setFilter] = useState("");

  const items = data?.items ?? [];

  const filtered = useMemo(() => {
    const needle = filter.trim().toLocaleLowerCase();
    if (!needle) return items;
    return items.filter((b) => targetTitle(b, lang).toLocaleLowerCase().includes(needle));
  }, [items, filter, lang]);

  return (
    <PageShell title={t("auth.saves")} subtitle={t("auth.saves_subtitle")}>
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3 font-mono text-[11px] text-ink-soft">
        {user && <span className="uppercase tracking-[1.6px]">{user.email}</span>}
        <button
          type="button"
          onClick={logout}
          className="cursor-pointer border border-rule bg-transparent px-3 py-1.5 uppercase tracking-[1.6px] hover:border-ink hover:text-ink"
        >
          {t("auth.sign_out")}
        </button>
      </div>

      <input
        type="search"
        placeholder={t("auth.search_placeholder")}
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        className="mb-6 w-full border border-rule bg-paper px-3 py-2 font-serif text-[15px] text-ink focus:border-accent focus:outline-none"
      />

      {isLoading && <Loading />}

      {!isLoading && filtered.length === 0 && (
        <p className="py-12 text-center font-serif italic text-ink-soft">{t("auth.saves_empty")}</p>
      )}

      <ul className="flex flex-col">
        {filtered.map((b) => (
          <li key={b.id} className="flex items-center justify-between gap-4 border-b border-rule-soft py-4">
            <Link to={detailHref(b)} className="iotd-link flex flex-1 flex-col gap-1.5">
              <span className="font-mono text-[10.5px] uppercase tracking-[1.6px] text-accent">
                {t(`auth.saves_kind_${b.targetKind}`)}
              </span>
              <span className="font-serif text-[18px] text-ink hover:underline">{targetTitle(b, lang)}</span>
            </Link>
            <button
              type="button"
              onClick={() => deleteMut.mutate(b.id)}
              disabled={deleteMut.isPending}
              className="cursor-pointer border border-rule bg-transparent px-3 py-1.5 font-mono text-[10.5px] uppercase tracking-[1.6px] text-ink-soft hover:border-ink hover:text-ink disabled:opacity-50"
            >
              {t("auth.remove")}
            </button>
          </li>
        ))}
      </ul>
    </PageShell>
  );
}

export const Route = createFileRoute("/saves")({
  component: SavesComponent,
});

function SavesComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  if (isInitialised && !isAuthenticated) {
    throw redirect({ to: "/sign-in" });
  }
  if (!isInitialised) return null;
  return <SavesPage />;
}
