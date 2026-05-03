import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import { pickLocalised, pickLocalisedList, useLanguage } from "@/providers/LanguageProvider";
import type { LessonDetail } from "@/api/generated/types.gen";
import { cn } from "@/lib/utils";

interface Props {
  lesson: LessonDetail;
}

export function LessonReader({ lesson }: Props) {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const localisedTitle = pickLocalised(
    { en: lesson.title, fr: lesson.titleFr, ar: lesson.titleAr },
    lang,
  );
  const localisedSummary = pickLocalised(
    { en: lesson.summary ?? "", fr: lesson.summaryFr, ar: lesson.summaryAr },
    lang,
  );
  const localisedBody = pickLocalisedList(
    { en: lesson.body ?? [], fr: lesson.bodyFr ?? null, ar: lesson.bodyAr ?? null },
    lang,
  );
  const showArabicCompanion = lang !== "ar" && Boolean(lesson.titleAr);
  const categoryLabel = t(lesson.category, lesson.category);

  return (
    <main className="iotd-main mx-auto max-w-[960px] px-[clamp(24px,4vw,56px)] pt-11 pb-[60px]">
      <div className="mb-4 flex flex-wrap items-center gap-3.5">
        <span className="font-mono text-[12px] uppercase tracking-[2px] text-accent">
          {categoryLabel}
        </span>
        <div className="h-[0.5px] min-w-3 flex-1 bg-rule" />
        <span className="font-mono text-[12px] uppercase tracking-[2px] text-ink-mute">
          {t("lesson")}
        </span>
      </div>

      <h1
        dir={isRTL ? "rtl" : "ltr"}
        className={cn(
          "mt-2.5 text-[clamp(32px,4vw,48px)] font-medium leading-[0.98] text-ink text-balance",
          lang === "ar" ? "font-arabic" : "font-serif tracking-[-1.6px]",
        )}
      >
        {localisedTitle}
      </h1>
      {showArabicCompanion && (
        <div className="mt-4 text-right font-arabic text-[32px] text-ink-soft" dir="rtl">
          {lesson.titleAr}
        </div>
      )}

      {lesson.reference && (
        <div className="mt-9 flex flex-wrap items-baseline gap-[18px]">
          <span className="font-serif text-[18px] italic text-ink">{lesson.reference}</span>
        </div>
      )}

      <FriezeRule label={t("introduction")} marginTop={10} marginBottom={14} />
      <p
        dir={isRTL ? "rtl" : "ltr"}
        className={cn(
          "mt-0 text-[20px] leading-[1.6] text-ink-soft text-pretty",
          lang === "ar" ? "font-arabic" : "font-serif italic tracking-[-0.2px]",
        )}
      >
        {localisedSummary}
      </p>

      {localisedBody.length > 0 && (
        <>
          <FriezeRule label={t("the_reading")} marginTop={36} marginBottom={20} />
          <div>
            {localisedBody.map((p, i) => (
              <p
                key={i}
                dir={isRTL ? "rtl" : "ltr"}
                className={cn(
                  "text-[17.5px] text-ink-soft text-pretty",
                  lang === "ar" ? "font-arabic leading-[1.9]" : "font-serif leading-[1.65]",
                  i === 0 ? "mt-0" : "mt-[18px]",
                )}
              >
                {p}
              </p>
            ))}
          </div>

          <FriezeRule marginTop={34} marginBottom={10} rosetteOnly />
          <div className="text-center font-mono text-[12px] uppercase tracking-[2px] text-ink-mute">
            {t("end_of_reading")}
          </div>
        </>
      )}
    </main>
  );
}
