import { Link, createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useEventListQuery } from "@/api/list";
import { FriezeRule } from "@/components/design";
import { EventCard } from "@/components/reader/EventCard";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { HIJRI_MONTHS_SHORT } from "@/i18n/months";
import { cn } from "@/lib/utils";

const HIJRI_MONTHS = HIJRI_MONTHS_SHORT;

const IMPORTANCE_TIERS = ["major", "notable", "minor"] as const;

interface BrowseSearch {
  era?: string;
  hijriMonth?: number;
  importance?: "major" | "notable" | "minor";
}

function BrowsePage() {
  const { t } = useTranslation();
  const search = Route.useSearch();
  const [page, setPage] = useState(0);
  const limit = 30;

  const query = useEventListQuery({
    era: search.era,
    hijriMonth: search.hijriMonth,
    importance: search.importance,
    limit,
    offset: page * limit,
  });

  const subtitle =
    describeFilter(search) || "Browse the curated record by era, Hijri month, or importance.";

  return (
    <PageShell title={t("browse")} subtitle={subtitle}>
      <FriezeRule label={t("importance")} marginTop={0} marginBottom={18} />
      <FilterRow>
        <FilterChip
          label="All"
          active={!search.importance}
          searchParams={{ ...search, importance: undefined }}
        />
        {IMPORTANCE_TIERS.map((imp) => (
          <FilterChip
            key={imp}
            label={t(imp, imp)}
            active={search.importance === imp}
            searchParams={{ ...search, importance: imp }}
          />
        ))}
      </FilterRow>

      <FriezeRule label={t("hijri_month")} marginTop={28} marginBottom={18} />
      <FilterRow>
        <FilterChip
          label="All months"
          active={!search.hijriMonth}
          searchParams={{ ...search, hijriMonth: undefined }}
        />
        {HIJRI_MONTHS.map((name, i) => (
          <FilterChip
            key={name}
            label={name}
            active={search.hijriMonth === i + 1}
            searchParams={{ ...search, hijriMonth: i + 1 }}
          />
        ))}
      </FilterRow>

      <FriezeRule
        label={
          query.data
            ? `${query.data.total} ${query.data.total === 1 ? t("results_one") : t("results_many")}`
            : "results"
        }
        marginTop={32}
        marginBottom={6}
      />

      {query.isPending && <Loading />}
      {query.isError && <Empty message={t("search_error")} />}
      {query.data && query.data.items.length === 0 && <Empty message={t("no_results")} />}
      {query.data && query.data.items.length > 0 && (
        <>
          {query.data.items.map((item) => (
            <EventCard key={item.id} item={item} />
          ))}
          <Pagination page={page} limit={limit} total={query.data.total} onPage={setPage} />
        </>
      )}
    </PageShell>
  );
}

function FilterRow({ children }: { children: React.ReactNode }) {
  return <div className="flex flex-wrap gap-2.5">{children}</div>;
}

interface ChipProps {
  label: string;
  active: boolean;
  searchParams: BrowseSearch;
}

function FilterChip({ label, active, searchParams }: ChipProps) {
  return (
    <Link
      to="/browse"
      search={searchParams}
      className={cn(
        "iotd-link font-mono px-3 py-1.5 text-[12px] uppercase tracking-[1.2px] border",
        active ? "border-ink bg-paper-hi text-ink" : "border-rule bg-transparent text-ink-soft",
      )}
    >
      {label}
    </Link>
  );
}

interface PaginationProps {
  page: number;
  limit: number;
  total: number;
  onPage: (n: number) => void;
}

function Pagination({ page, limit, total, onPage }: PaginationProps) {
  const { t } = useTranslation();
  const last = Math.max(0, Math.ceil(total / limit) - 1);
  if (last === 0) return null;
  return (
    <div className="mt-6 flex items-center justify-center gap-4 font-mono text-[12px] uppercase tracking-[1.4px] text-ink-mute">
      <button
        type="button"
        onClick={() => onPage(Math.max(0, page - 1))}
        disabled={page === 0}
        className={cn(
          "border border-rule bg-transparent px-3 py-1.5",
          page === 0 ? "cursor-not-allowed text-ink-faint" : "cursor-pointer text-ink",
        )}
      >
        {t("prev")}
      </button>
      <span>
        page {page + 1} / {last + 1}
      </span>
      <button
        type="button"
        onClick={() => onPage(Math.min(last, page + 1))}
        disabled={page >= last}
        className={cn(
          "border border-rule bg-transparent px-3 py-1.5",
          page >= last ? "cursor-not-allowed text-ink-faint" : "cursor-pointer text-ink",
        )}
      >
        {t("next")}
      </button>
    </div>
  );
}

function describeFilter(s: BrowseSearch): string | null {
  const parts: string[] = [];
  if (s.importance) parts.push(`importance · ${s.importance}`);
  if (s.hijriMonth) parts.push(`Hijri month · ${HIJRI_MONTHS[s.hijriMonth - 1]}`);
  if (s.era) parts.push(`era · ${s.era}`);
  return parts.length ? parts.join("  ·  ") : null;
}

export const Route = createFileRoute("/browse")({
  component: BrowsePage,
  validateSearch: (search: Record<string, unknown>): BrowseSearch => {
    const era = typeof search.era === "string" ? search.era : undefined;
    const importance =
      search.importance === "major" ||
      search.importance === "notable" ||
      search.importance === "minor"
        ? search.importance
        : undefined;
    const month = Number(search.hijriMonth);
    const hijriMonth = Number.isFinite(month) && month >= 1 && month <= 12 ? month : undefined;
    return { era, importance, hijriMonth };
  },
});
