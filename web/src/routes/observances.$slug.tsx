import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { useObservanceQuery } from "@/api/observances";
import { FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { HIJRI_MONTHS_LONG } from "@/i18n/months";

function ObservancePage() {
  const { slug } = Route.useParams();
  const { t } = useTranslation();
  const query = useObservanceQuery(slug);

  return (
    <PageShell title={`${t("observance_label")} · ${slug}`}>
      {query.isPending && <Loading labelKey="loading_observance" />}
      {query.isError && <Empty message={`${t("no_observance_with_slug")} "${slug}".`} />}
      {query.data && (
        <article>
          <div className="mb-3 font-mono text-[11.5px] uppercase tracking-[2px] text-accent">
            {query.data.hijriDay ?? ""} {HIJRI_MONTHS_LONG[query.data.hijriMonth - 1]} ·{" "}
            {t(query.data.importance, query.data.importance)}
          </div>
          <h1 className="m-0 text-[clamp(32px,4vw,48px)] font-serif font-medium leading-none tracking-[-1.4px] text-ink text-balance">
            {query.data.nameEn}
          </h1>
          {query.data.nameAr && (
            <div className="mt-4 text-right font-arabic text-[32px] text-ink-soft" dir="rtl">
              {query.data.nameAr}
            </div>
          )}

          <FriezeRule label={t("the_reading")} marginTop={36} marginBottom={20} />
          {query.data.descriptionEn.split("\n\n").map((p, i) => (
            <p
              key={i}
              className={`font-serif text-[18.5px] leading-[1.65] text-ink-soft text-pretty ${i === 0 ? "mt-0" : "mt-[18px]"}`}
            >
              {p}
            </p>
          ))}

          {(query.data.quranRefs || query.data.hadithRefs) && (
            <>
              <FriezeRule label={t("references")} marginTop={32} marginBottom={16} />
              {query.data.quranRefs && (
                <div className="border-b border-rule-soft py-2.5">
                  <div className="font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                    Qur'ān
                  </div>
                  <div className="mt-1.5 font-serif text-[17px] text-ink">
                    {query.data.quranRefs}
                  </div>
                </div>
              )}
              {query.data.hadithRefs && (
                <div className="border-b border-rule-soft py-2.5">
                  <div className="font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">
                    Ḥadīth
                  </div>
                  <div className="mt-1.5 font-serif text-[17px] text-ink">
                    {query.data.hadithRefs}
                  </div>
                </div>
              )}
            </>
          )}
        </article>
      )}
    </PageShell>
  );
}

export const Route = createFileRoute("/observances/$slug")({
  component: ObservancePage,
});
