import { Link, createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { getRecentApiV1RecentGetOptions } from "@/api/generated/@tanstack/react-query.gen";
import { FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import type { EventDetail } from "@/api/generated/types.gen";

function isEventDetail(headline: unknown): headline is EventDetail {
  return headline !== null && typeof headline === "object" && !("kind" in headline);
}

function RecentPage() {
  const { t } = useTranslation();
  const query = useQuery(getRecentApiV1RecentGetOptions());

  return (
    <PageShell title="Recent" subtitle="Headline and observance for the last 7 calendar days.">
      {query.isPending && <Loading />}
      {query.isError && <Empty message={t("search_error")} />}
      {query.data && query.data.days.length === 0 && <Empty message={t("no_results")} />}
      {query.data && query.data.days.length > 0 && (
        <>
          {query.data.days.map((day) => {
            const headline = day.headline;
            const isEvent = isEventDetail(headline);
            const to = isEvent ? "/events/$slug" : "/lessons/$slug";
            return (
              <div
                key={day.date}
                className="grid grid-cols-[140px_1fr] items-baseline gap-6 border-b border-rule-soft py-5"
              >
                <div>
                  <div className="font-serif text-[28px] font-medium leading-none tracking-[-0.8px] text-ink">
                    {day.calendar.gregorian.day}
                  </div>
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                    {day.calendar.gregorian.month}
                  </div>
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.8px] text-accent">
                    {day.calendar.hijri.day} {day.calendar.hijri.month}
                  </div>
                </div>
                <div>
                  {headline ? (
                    <Link
                      to={to}
                      params={{ slug: headline.id }}
                      className="iotd-link font-serif text-[20px] font-medium leading-[1.15] tracking-[-0.3px] text-ink"
                    >
                      {headline.title}
                    </Link>
                  ) : (
                    <div className="font-serif text-[16px] italic text-ink-mute">
                      No headline for this day
                    </div>
                  )}
                  {day.observance && (
                    <div className="mt-2 font-mono text-[11px] uppercase tracking-[0.8px] text-accent">
                      {day.observance.name}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
          <FriezeRule marginTop={36} marginBottom={10} rosetteOnly />
        </>
      )}
    </PageShell>
  );
}

export const Route = createFileRoute("/recent")({
  component: RecentPage,
});
