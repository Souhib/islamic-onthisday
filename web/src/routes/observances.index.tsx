import { Link, createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { useObservancesQuery } from "@/api/observances";
import { FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { HIJRI_MONTHS_LONG } from "@/i18n/months";
import { cn } from "@/lib/utils";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";

function ObservancesPage() {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const query = useObservancesQuery();

  return (
    <PageShell
      title={t("observances")}
      subtitle="Recurring annual rites — fixed by Hijri date, ordered through the Muslim year."
    >
      {query.isPending && <Loading />}
      {query.isError && <Empty message={t("load_failed")} />}
      {query.data && query.data.length > 0 && (
        <>
          {query.data.map((obs) => (
            <Link
              key={obs.id}
              to="/observances/$slug"
              params={{ slug: obs.id }}
              className="iotd-link grid grid-cols-[120px_1fr] items-baseline gap-6 border-b border-rule-soft py-5"
            >
              <div>
                <div className="font-serif text-[38px] font-medium leading-none tracking-[-1.2px] text-ink">
                  {obs.hijriDay ?? "—"}
                </div>
                <div className="mt-1 font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                  {HIJRI_MONTHS_LONG[obs.hijriMonth - 1]}
                </div>
                {(obs.windowDays ?? 0) > 1 && (
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.8px] text-accent">
                    {obs.windowDays}-day window
                  </div>
                )}
              </div>
              <div>
                <div
                  dir={isRTL ? "rtl" : "ltr"}
                  className={cn(
                    "text-[22px] font-medium leading-[1.15] text-ink",
                    lang === "ar" ? "font-arabic" : "font-serif tracking-[-0.3px]",
                  )}
                >
                  {pickLocalised(
                    { en: obs.nameEn, fr: obs.nameFr ?? null, ar: obs.nameAr ?? null },
                    lang,
                  )}
                </div>
                {lang !== "ar" && obs.nameAr && (
                  <div className="mt-1.5 font-arabic text-[20px] text-ink-soft" dir="rtl">
                    {obs.nameAr}
                  </div>
                )}
                <div className="mt-2 font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                  {t(obs.importance, obs.importance)}
                </div>
              </div>
            </Link>
          ))}
          <FriezeRule marginTop={36} marginBottom={10} rosetteOnly />
        </>
      )}
    </PageShell>
  );
}

export const Route = createFileRoute("/observances/")({
  component: ObservancesPage,
});
