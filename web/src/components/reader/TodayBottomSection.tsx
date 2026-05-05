import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import type { EventSummary, LessonSummary } from "@/api/generated/types.gen";
import { reorderRefsQuranFirst } from "@/lib/refs";

// Break a freeform reference string into one piece per line, Qur'an-first.
// Used in the bottom-section cards so a wrap doesn't split a single ref
// (e.g. "Qur'an" on one line, "18:32-44" on the next).
//
// Splits on ``;`` always (the dataset's primary separator). Splits on
// ``,`` too, except when the comma is between two surah:ayah groups —
// "Qur'an 2:255, 3:97" is a single multi-ayah citation and stays whole;
// "Sahih al-Bukhari 5013, Sahih al-Bukhari 5015" is two refs and breaks.
function refLines(reference: string | null | undefined): string[] {
  const reordered = reorderRefsQuranFirst(reference);
  if (!reordered) return [];
  const pieces: string[] = [];
  for (const semiPart of reordered.split(";")) {
    // Split on commas NOT followed by ``\d+:\d+`` (which would mean the
    // comma is inside a multi-ayah Qur'an citation).
    const subPieces = semiPart.split(/,(?!\s*\d+:\d+)/);
    for (const sub of subPieces) {
      const trimmed = sub.trim();
      if (trimmed) pieces.push(trimmed);
    }
  }
  return pieces;
}

interface BottomItem {
  item: EventSummary | LessonSummary;
  isHeadline: boolean;
}

interface Props {
  items: BottomItem[];
  onPick: (id: string, isLesson: boolean) => void;
}

function isLessonSummary(value: EventSummary | LessonSummary): value is LessonSummary {
  return "kind" in value && value.kind === "lesson";
}

export function TodayBottomSection({ items, onPick }: Props) {
  const { t } = useTranslation();
  const { lang } = useLanguage();
  if (items.length === 0) return null;

  return (
    <section className="border-t border-rule px-[clamp(20px,4vw,56px)] pt-12 pb-[60px]">
      <FriezeRule label={t("more_reading_for_today")} marginTop={0} marginBottom={28} />
      <div className="mx-auto flex max-w-[1080px] flex-wrap justify-around">
        {items.map(({ item, isHeadline }) => {
          const isLesson = isLessonSummary(item);
          const meta = isLesson
            ? t(item.category, item.category)
            : (item.era ? t(item.era, item.era) : "") || item.hijri || "";
          const hijri = isLesson ? null : item.hijri;
          // Lessons cite scripture in a freeform ``reference`` string —
          // split it into its semicolon-separated pieces (Qur'an first)
          // so each citation gets its own line and never breaks mid-ref.
          // Events keep the single-line Gregorian date.
          const eventDate = isLesson ? null : item.gregorian;
          const lessonRefLines = isLesson ? refLines(item.reference) : [];
          const localisedTitle = pickLocalised(
            { en: item.title, fr: item.titleFr, ar: item.titleAr },
            lang,
          );

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => onPick(item.id, isLesson)}
              className="iotd-pick"
              style={{
                display: "flex",
                flexDirection: "column",
                width: 280,
                flexShrink: 0,
                margin: "0 32px",
                padding: "24px 0",
                textAlign: "left",
                borderBottom: "0.5px solid var(--rule-soft)",
              }}
            >
              <div className="flex h-5 items-center">
                {isHeadline ? (
                  <span className="inline-flex items-center border border-accent/45 bg-accent/[0.08] px-2 py-[1px] font-mono text-[10.5px] uppercase tracking-[1.6px] text-accent">
                    {t("todays_featured_event")}
                  </span>
                ) : (
                  <span aria-hidden="true">&nbsp;</span>
                )}
              </div>

              <div className="mt-1.5 h-[18px] overflow-hidden whitespace-nowrap font-mono text-[13px] uppercase leading-[18px] tracking-[1.4px] text-accent text-ellipsis">
                {meta}
              </div>

              <div className="mt-2 font-serif text-[18px] font-medium leading-[1.15] tracking-[-0.3px] text-ink text-pretty">
                {localisedTitle}
              </div>

              {(hijri || eventDate) && (
                <div className="mt-2.5 flex flex-wrap items-baseline gap-3.5">
                  {hijri && <span className="font-serif text-[16px] italic text-ink">{hijri}</span>}
                  {eventDate && (
                    <span className="font-mono text-[14px] tracking-[0.6px] text-ink-mute">
                      {eventDate}
                    </span>
                  )}
                </div>
              )}

              {lessonRefLines.length > 0 && (
                <ul className="mt-2.5 flex flex-col gap-1">
                  {lessonRefLines.map((line, i) => (
                    <li
                      key={i}
                      className="font-mono text-[13px] leading-[1.35] tracking-[0.4px] text-ink-mute"
                    >
                      {line}
                    </li>
                  ))}
                </ul>
              )}
            </button>
          );
        })}
      </div>
    </section>
  );
}
