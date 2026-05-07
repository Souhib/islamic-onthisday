import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import type { EventDetail, LessonDetail, ObservanceRef } from "@/api/generated/types.gen";
import { parseHadithRef, parseQuranRef, reorderRefsQuranFirst, splitRefs } from "@/lib/refs";
import { cn } from "@/lib/utils";

interface Props {
  item: EventDetail | LessonDetail | null;
  observance: ObservanceRef | null;
}

function isLessonDetail(item: EventDetail | LessonDetail | null): item is LessonDetail {
  return item !== null && typeof item === "object" && "kind" in item && item.kind === "lesson";
}

const RAIL_CLASS =
  "thaqafa-rail-right border-l border-rule pt-11 pb-10 pl-7 pr-[clamp(20px,4vw,56px)]";
const ROW_CLASS = "border-b border-rule-soft py-2.5";

export function RightRail({ item, observance }: Props) {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();

  if (item && !isLessonDetail(item)) {
    const ev = item;
    const people = ev.people ?? [];
    const sources = ev.sources ?? [];
    return (
      <aside className={RAIL_CLASS}>
        {people.length > 0 && (
          <>
            <FriezeRule label={t("people")} marginTop={0} marginBottom={14} />
            <div>
              {people.map((p) => (
                <Link
                  key={p.id}
                  to="/people/$slug"
                  params={{ slug: p.id }}
                  className={`thaqafa-link thaqafa-pick ${ROW_CLASS}`}
                >
                  <div className="font-serif text-[17px] font-medium leading-[1.15] text-ink">
                    {p.name}
                  </div>
                  {p.role && (
                    <div className="mt-1 font-mono text-[13px] tracking-[0.5px] text-ink-mute">
                      {p.role}
                    </div>
                  )}
                </Link>
              ))}
            </div>
          </>
        )}

        {sources.length > 0 && (
          <>
            <FriezeRule label={t("sources")} marginTop={28} marginBottom={14} />
            <div>
              {sources.map((s, i) => {
                const inner = (
                  <>
                    <div
                      className={`font-serif text-[15.5px] font-medium leading-[1.25] text-ink ${
                        s.kind === "classical" ? "italic" : ""
                      }`}
                    >
                      {s.label}
                    </div>
                    <div className="mt-1 font-mono text-[12.5px] uppercase tracking-[0.6px] text-ink-mute">
                      {t(s.kind, s.kind)} {s.verify ? `· ${t("verify")}` : ""}
                    </div>
                  </>
                );
                return (
                  <div key={i} className={ROW_CLASS}>
                    {s.verify ? (
                      <a className="thaqafa-link" href={s.verify} target="_blank" rel="noreferrer">
                        {inner}
                      </a>
                    ) : (
                      inner
                    )}
                  </div>
                );
              })}
            </div>
          </>
        )}
      </aside>
    );
  }

  if (item && isLessonDetail(item)) {
    const lesson = item;
    const quran = lesson.quranRefs ?? null;
    const hadith = lesson.hadithRefs ?? null;
    const reference = lesson.reference ?? null;
    const sourceUrl = lesson.sourceUrl ?? null;
    const hasAny = quran || hadith || reference || sourceUrl;
    const notes = pickLocalised(
      {
        en: lesson.sourceNotes ?? null,
        fr: lesson.sourceNotesFr ?? null,
        ar: lesson.sourceNotesAr ?? null,
      },
      lang,
    );

    return (
      <aside className={RAIL_CLASS}>
        {hasAny && (
          <>
            <FriezeRule label={t("references")} marginTop={0} marginBottom={14} />

            {reference && (
              <div className={ROW_CLASS}>
                <div className="font-serif text-[16.5px] font-medium leading-[1.2] text-ink">
                  {reorderRefsQuranFirst(reference)}
                </div>
                <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute">
                  {t("primary")}
                </div>
              </div>
            )}

            {splitRefs(quran).map((raw, i) => {
              const parsed = parseQuranRef(raw);
              const display = parsed?.display ?? raw;
              const url = parsed?.url ?? null;
              const refRow = (
                <>
                  <div className="font-serif text-[14px] font-medium leading-[1.25] text-ink">
                    {display}
                  </div>
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute">
                    {url ? `${t("quran_label")} · ${t("verify")}` : t("primary")}
                  </div>
                </>
              );
              return (
                <div key={`q-${i}`} className={ROW_CLASS}>
                  {url ? (
                    <a className="thaqafa-link" href={url} target="_blank" rel="noreferrer">
                      {refRow}
                    </a>
                  ) : (
                    refRow
                  )}
                </div>
              );
            })}

            {splitRefs(hadith).map((raw, i) => {
              const parsed = parseHadithRef(raw);
              const display = parsed?.display ?? raw;
              const url = parsed?.url ?? null;
              const refRow = (
                <>
                  <div className="font-serif text-[14px] font-medium leading-[1.25] text-ink">
                    {display}
                  </div>
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute">
                    {url ? `${t("hadith_label")} · ${t("verify")}` : t("hadith_label")}
                  </div>
                </>
              );
              return (
                <div key={`h-${i}`} className={ROW_CLASS}>
                  {url ? (
                    <a className="thaqafa-link" href={url} target="_blank" rel="noreferrer">
                      {refRow}
                    </a>
                  ) : (
                    refRow
                  )}
                </div>
              );
            })}

            {sourceUrl && (
              <div className={ROW_CLASS}>
                <div className="font-serif text-[14px] font-medium leading-[1.25] text-ink">
                  {(() => {
                    try {
                      return new URL(sourceUrl).hostname.replace(/^www\./, "");
                    } catch {
                      return "Source";
                    }
                  })()}
                </div>
                <a className="thaqafa-link" href={sourceUrl} target="_blank" rel="noreferrer">
                  <div className="mt-1 font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute">
                    {t("verify")}
                  </div>
                </a>
              </div>
            )}

            {notes && (
              <>
                <FriezeRule label={t("scholarly_views_label")} marginTop={28} marginBottom={14} />
                <p className="font-serif text-[16.5px] italic leading-[1.6] text-ink-soft text-pretty">
                  {notes}
                </p>
              </>
            )}
          </>
        )}
      </aside>
    );
  }

  return (
    <aside className={RAIL_CLASS}>
      {observance ? (
        (() => {
          const obsName = pickLocalised(
            { en: observance.name, fr: observance.nameFr ?? null, ar: observance.nameAr ?? null },
            lang,
          );
          const obsSummary = pickLocalised(
            {
              en: observance.summary ?? null,
              fr: observance.summaryFr ?? null,
              ar: observance.summaryAr ?? null,
            },
            lang,
          );
          return (
            <>
              <FriezeRule label={t("observance_label")} marginTop={0} marginBottom={14} />
              <div
                dir={isRTL ? "rtl" : "ltr"}
                className={cn(
                  "text-[18px] font-medium leading-[1.2] tracking-[-0.2px] text-ink",
                  lang === "ar" ? "font-arabic" : "font-serif",
                )}
              >
                {obsName}
              </div>
              {obsSummary && (
                <p
                  dir={isRTL ? "rtl" : "ltr"}
                  className={cn(
                    "mt-2 text-[13.5px] leading-[1.5] text-ink-soft text-pretty",
                    lang === "ar" ? "font-arabic" : "font-serif italic",
                  )}
                >
                  {obsSummary}
                </p>
              )}
            </>
          );
        })()
      ) : (
        <div className="mt-10 font-mono text-[12px] uppercase tracking-[1.4px] text-ink-mute">
          · {t("on_this_day")} ·
        </div>
      )}
    </aside>
  );
}
