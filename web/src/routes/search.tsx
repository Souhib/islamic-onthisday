import { createFileRoute } from "@tanstack/react-router";
import { useDeferredValue, useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import { useSearchQuery } from "@/api/list";
import { FriezeRule } from "@/components/design";
import { EventCard } from "@/components/reader/EventCard";
import { PageShell } from "@/components/reader/PageShell";
import { trackSearch } from "@/lib/analytics";

function SearchPage() {
  const { t } = useTranslation();
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [q, setQ] = useState("");
  const deferredQ = useDeferredValue(q);
  const query = useSearchQuery(deferredQ);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  // One analytics event per *successful* search resolution. We watch the
  // deferred term so users typing fast don't generate one event per
  // keystroke — only the value React actually rendered with counts.
  useEffect(() => {
    if (!query.isSuccess || !query.data) return;
    if (deferredQ.trim().length < 2) return;
    trackSearch(deferredQ, query.data.total);
  }, [query.isSuccess, query.data, deferredQ]);

  return (
    <PageShell title={t("search")} subtitle={t("search_subtitle")}>
      <div className="border-y border-rule py-4">
        <input
          ref={inputRef}
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="al-Ghazālī, Karbalāʾ, Granada, …"
          aria-label={t("search")}
          className="w-full border-0 bg-transparent font-serif text-[clamp(28px,5vw,48px)] tracking-[-0.6px] text-ink outline-none"
        />
      </div>

      {q.trim().length > 0 && q.trim().length < 2 && <Hint text={t("search_min_chars")} />}

      {q.trim().length >= 2 && query.isPending && <Hint text={`· ${t("searching")} ·`} />}
      {query.isError && <Hint text={t("search_error")} />}

      {query.data && (
        <>
          <FriezeRule
            label={
              query.data.total === 0
                ? t("no_results")
                : `${query.data.total} ${query.data.total === 1 ? t("results_one") : t("results_many")}`
            }
            marginTop={28}
            marginBottom={6}
          />
          {query.data.items.map((item) => (
            <EventCard key={item.id} item={item} />
          ))}
        </>
      )}
    </PageShell>
  );
}

function Hint({ text }: { text: string }) {
  return (
    <div className="py-8 text-center font-mono text-[12px] uppercase tracking-[2px] text-ink-mute">
      {text}
    </div>
  );
}

export const Route = createFileRoute("/search")({
  component: SearchPage,
});
