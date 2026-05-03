import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { usePersonQuery } from "@/api/people";
import { FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { trackPersonView } from "@/lib/analytics";

function PersonPage() {
  const { slug } = Route.useParams();
  const { t } = useTranslation();
  const query = usePersonQuery(slug);

  useEffect(() => {
    trackPersonView(slug);
  }, [slug]);

  return (
    <PageShell title={`${t("person")} · ${slug}`}>
      {query.isPending && <Loading labelKey="loading_person" />}
      {query.isError && <Empty message={`${t("no_person_with_slug")} "${slug}".`} />}
      {query.data && (
        <article>
          <div className="mb-3 font-mono text-[11.5px] uppercase tracking-[2px] text-accent">
            {t("person")}
            {query.data.role ? ` · ${query.data.role}` : ""}
          </div>
          <h1 className="m-0 text-[clamp(32px,4vw,48px)] font-serif font-medium leading-none tracking-[-1.4px] text-ink text-balance">
            {query.data.fullNameEn}
          </h1>
          {query.data.fullNameAr && (
            <div className="mt-4 text-right font-arabic text-[32px] text-ink-soft" dir="rtl">
              {query.data.fullNameAr}
            </div>
          )}

          {query.data.imageBlockedReason && (
            <div className="mt-6 border border-rule px-4 py-3 font-mono text-[12px] uppercase tracking-[1.2px] text-ink-mute">
              · No image · religious image policy ({query.data.imageBlockedReason}) ·
            </div>
          )}

          {(query.data.kunya || query.data.laqab || query.data.nisba) && (
            <>
              <FriezeRule label={t("names")} marginTop={32} marginBottom={16} />
              <NamePart label="Kunya" value={query.data.kunya ?? null} />
              <NamePart label="Laqab" value={query.data.laqab ?? null} />
              <NamePart label="Nisba" value={query.data.nisba ?? null} />
            </>
          )}

          {query.data.biography && (
            <>
              <FriezeRule label={t("biography")} marginTop={32} marginBottom={16} />
              {query.data.biography.split("\n\n").map((p, i) => (
                <p
                  key={i}
                  className={`font-serif text-[17.5px] leading-[1.65] text-ink-soft text-pretty ${i === 0 ? "mt-0" : "mt-[18px]"}`}
                >
                  {p}
                </p>
              ))}
            </>
          )}

          {query.data.wikidataQid && (
            <>
              <FriezeRule label={t("external")} marginTop={32} marginBottom={16} />
              <a
                className="iotd-link font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute"
                href={`https://www.wikidata.org/wiki/${query.data.wikidataQid}`}
                target="_blank"
                rel="noreferrer"
              >
                Wikidata · {query.data.wikidataQid} · verify ↗
              </a>
            </>
          )}
        </article>
      )}
    </PageShell>
  );
}

function NamePart({ label, value }: { label: string; value: string | null }) {
  if (!value) return null;
  return (
    <div className="border-b border-rule-soft py-2">
      <div className="font-mono text-[11px] uppercase tracking-[1.2px] text-ink-mute">{label}</div>
      <div className="mt-1 font-serif text-[17px] text-ink">{value}</div>
    </div>
  );
}

export const Route = createFileRoute("/people/$slug")({
  component: PersonPage,
});
