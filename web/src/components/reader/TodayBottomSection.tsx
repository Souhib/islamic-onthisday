import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import type { EventSummary, LessonSummary } from "@/api/generated/types.gen";

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
          const gregorian = isLesson ? item.reference : item.gregorian;
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
              <div className="h-5 overflow-hidden font-mono text-[13px] uppercase leading-[20px] tracking-[1.6px] text-accent">
                {isHeadline ? `· ${t("todays_featured_event")} ·` : " "}
              </div>

              <div className="mt-1.5 h-[18px] overflow-hidden whitespace-nowrap font-mono text-[13px] uppercase leading-[18px] tracking-[1.4px] text-accent text-ellipsis">
                {meta}
              </div>

              <div className="mt-2 font-serif text-[18px] font-medium leading-[1.15] tracking-[-0.3px] text-ink text-pretty">
                {localisedTitle}
              </div>

              <div className="mt-2.5 flex flex-wrap items-baseline gap-3.5">
                {hijri && <span className="font-serif text-[16px] italic text-ink">{hijri}</span>}
                {gregorian && (
                  <span className="font-mono text-[14px] tracking-[0.6px] text-ink-mute">
                    {gregorian}
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>
    </section>
  );
}
