import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useObservanceQuery } from "@/api/observances";
import { SaveButton } from "@/components/bookmark/SaveButton";
import { FriezeRule } from "@/components/design";
import { BackToTodayCTA } from "@/components/reader/BackToTodayCTA";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { HIJRI_MONTHS_LONG } from "@/i18n/months";
import { trackObservanceView } from "@/lib/analytics";
import { parseHadithRef, parseQuranRef, splitRefs } from "@/lib/refs";
import { cn } from "@/lib/utils";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";

function ObservancePage() {
  const { slug } = Route.useParams();
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const query = useObservanceQuery(slug);

  useEffect(() => {
    trackObservanceView(slug);
  }, [slug]);

  const localisedName = query.data
    ? pickLocalised(
        { en: query.data.nameEn, fr: query.data.nameFr ?? null, ar: query.data.nameAr ?? null },
        lang,
      )
    : null;
  const localisedDescription = query.data
    ? pickLocalised(
        {
          en: query.data.descriptionEn,
          fr: query.data.descriptionFr ?? null,
          ar: query.data.descriptionAr ?? null,
        },
        lang,
      )
    : null;
  const showArabicCompanion = lang !== "ar" && Boolean(query.data?.nameAr);

  return (
    <PageShell title={`${t("observance_label")} · ${slug}`}>
      {query.isPending && <Loading labelKey="loading_observance" />}
      {query.isError && <Empty message={`${t("no_observance_with_slug")} "${slug}".`} />}
      {query.data && (
        <article>
          <div className="mb-3 flex items-center justify-between gap-3 font-mono text-[11.5px] uppercase tracking-[2px] text-accent">
            <span>
              {query.data.hijriDay ?? ""} {HIJRI_MONTHS_LONG[query.data.hijriMonth - 1]} ·{" "}
              {t(query.data.importance, query.data.importance)}
            </span>
            <SaveButton targetKind="observance" targetSlug={slug} />
          </div>
          <h1
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "m-0 text-[clamp(32px,4vw,48px)] font-medium leading-none text-ink text-balance",
              lang === "ar" ? "font-arabic" : "font-serif tracking-[-1.4px]",
            )}
          >
            {localisedName}
          </h1>
          {showArabicCompanion && (
            <div className="mt-4 text-right font-arabic text-[32px] text-ink-soft" dir="rtl">
              {query.data.nameAr}
            </div>
          )}

          <FriezeRule label={t("the_reading")} marginTop={36} marginBottom={20} />
          {(localisedDescription ?? "").split("\n\n").map((p, i) => (
            <p
              key={i}
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "text-[18.5px] text-ink-soft text-pretty",
                lang === "ar" ? "font-arabic leading-[1.9]" : "font-serif leading-[1.65]",
                i === 0 ? "mt-0" : "mt-[18px]",
              )}
            >
              {p}
            </p>
          ))}

          {(query.data.quranRefs || query.data.hadithRefs) && (
            <>
              <FriezeRule label={t("references")} marginTop={32} marginBottom={16} />
              {splitRefs(query.data.quranRefs).map((raw, i) => {
                const parsed = parseQuranRef(raw);
                const display = parsed?.display ?? raw;
                const url = parsed?.url ?? null;
                const inner = (
                  <>
                    <div className="font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                      {t("quran_label")}
                    </div>
                    <div className="mt-1.5 font-serif text-[17px] text-ink">{display}</div>
                  </>
                );
                return (
                  <div key={`q-${i}`} className="border-b border-rule-soft py-2.5">
                    {url ? (
                      <a className="thaqafa-link" href={url} target="_blank" rel="noreferrer">
                        {inner}
                      </a>
                    ) : (
                      inner
                    )}
                  </div>
                );
              })}
              {splitRefs(query.data.hadithRefs).map((raw, i) => {
                const parsed = parseHadithRef(raw);
                const display = parsed?.display ?? raw;
                const url = parsed?.url ?? null;
                const inner = (
                  <>
                    <div className="font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                      {t("hadith_label")}
                    </div>
                    <div className="mt-1.5 font-serif text-[17px] text-ink">{display}</div>
                  </>
                );
                return (
                  <div key={`h-${i}`} className="border-b border-rule-soft py-2.5">
                    {url ? (
                      <a className="thaqafa-link" href={url} target="_blank" rel="noreferrer">
                        {inner}
                      </a>
                    ) : (
                      inner
                    )}
                  </div>
                );
              })}
            </>
          )}
          <BackToTodayCTA />
        </article>
      )}
    </PageShell>
  );
}

export const Route = createFileRoute("/observances/$slug")({
  component: ObservancePage,
});
