import { Link, createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { getRecentApiV1RecentGetOptions } from "@/api/generated/@tanstack/react-query.gen";
import { FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { cn } from "@/lib/utils";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import type { EventDetail } from "@/api/generated/types.gen";

function isEventDetail(headline: unknown): headline is EventDetail {
  return headline !== null && typeof headline === "object" && !("kind" in headline);
}

function RecentPage() {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const query = useQuery(getRecentApiV1RecentGetOptions());

  return (
    <PageShell title={t("recent")} subtitle={t("recent_subtitle")}>
      {query.isPending && <Loading />}
      {query.isError && <Empty message={t("recent_load_failed")} />}
      {query.data && query.data.days.length > 0 && (
        <>
          {query.data.days.map((day) => {
            const headline = day.headline;
            const isEvent = isEventDetail(headline);
            const to = isEvent ? "/events/$slug" : "/lessons/$slug";
            const headlineTitle = headline
              ? pickLocalised(
                  {
                    en: headline.title,
                    fr: headline.titleFr ?? null,
                    ar: headline.titleAr ?? null,
                  },
                  lang,
                )
              : null;
            const observanceName = day.observance
              ? pickLocalised(
                  {
                    en: day.observance.name,
                    fr: day.observance.nameFr ?? null,
                    ar: day.observance.nameAr ?? null,
                  },
                  lang,
                )
              : null;
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
                  {headline && headlineTitle ? (
                    <Link
                      to={to}
                      params={{ slug: headline.id }}
                      dir={isRTL ? "rtl" : "ltr"}
                      className={cn(
                        "thaqafa-link text-[20px] font-medium leading-[1.15] text-ink",
                        lang === "ar" ? "font-arabic" : "font-serif tracking-[-0.3px]",
                      )}
                    >
                      {headlineTitle}
                    </Link>
                  ) : (
                    <div className="font-serif text-[16px] italic text-ink-mute">
                      {t("recent_no_headline")}
                    </div>
                  )}
                  {observanceName && (
                    <div
                      dir={isRTL ? "rtl" : "ltr"}
                      className={cn(
                        "mt-2 text-[11px] uppercase tracking-[0.8px] text-accent",
                        lang === "ar" ? "font-arabic" : "font-mono",
                      )}
                    >
                      {observanceName}
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
