import { useTranslation } from "react-i18next";
import { SaveButton } from "@/components/bookmark/SaveButton";
import {
  FriezeRule,
  VerificationChip,
  isVerificationKind,
  type VerificationKind,
} from "@/components/design";
import { DisputeBadge, type DisputeAbout } from "@/components/disputed/DisputeBadge";
import { pickLocalised, pickLocalisedList, useLanguage } from "@/providers/LanguageProvider";
import type { EventDetail } from "@/api/generated/types.gen";
import { formatGregorianDDMMYYYY, formatGregorianLong } from "@/lib/dates";
import { cn } from "@/lib/utils";

interface Props {
  ev: EventDetail;
  onOpenDispute: () => void;
}

export function Main({ ev, onOpenDispute }: Props) {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const localisedTitle = pickLocalised({ en: ev.title, fr: ev.titleFr, ar: ev.titleAr }, lang);
  const localisedSummary = pickLocalised(
    { en: ev.summary, fr: ev.summaryFr, ar: ev.summaryAr },
    lang,
  );
  const localisedBody = pickLocalisedList(
    { en: ev.body ?? [], fr: ev.bodyFr ?? null, ar: ev.bodyAr ?? null },
    lang,
  );
  const showArabicCompanion = lang !== "ar" && Boolean(ev.titleAr);

  const eraLabel = ev.era ? t(ev.era, ev.era) : "";
  const verificationKind: VerificationKind = isVerificationKind(ev.verificationStatus)
    ? ev.verificationStatus
    : "unverified";
  const verificationLabel = t(verificationKind);
  const disputeLabel = ev.disputeAbout ? t(`dispute_${ev.disputeAbout}`) : null;

  return (
    <main className="iotd-main mx-auto max-w-[960px] px-[clamp(24px,4vw,56px)] pt-11 pb-[60px]">
      <div className="mb-4 flex flex-wrap items-center gap-3.5">
        <span className="font-mono text-[12px] uppercase tracking-[2px] text-accent">
          {eraLabel}
        </span>
        <div className="h-[0.5px] min-w-3 flex-1 bg-rule" />
        <VerificationChip kind={verificationKind} label={verificationLabel} />
        {ev.disputed && (
          <DisputeBadge
            disputeAbout={ev.disputeAbout as DisputeAbout}
            size="sm"
            onClick={onOpenDispute}
            label={disputeLabel ?? undefined}
          />
        )}
        <SaveButton targetKind="event" targetSlug={ev.id} />
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
          {ev.titleAr}
        </div>
      )}

      <div className="mt-[28px] mb-3 flex flex-wrap items-baseline gap-[18px]">
        {ev.hijri && <span className="font-serif text-[18px] italic text-ink">{ev.hijri}</span>}
        {ev.gregorian && (
          <>
            <span className="font-serif text-[16px] italic text-ink-soft">
              · {formatGregorianLong(ev.gregorian, lang)}
            </span>
            <span className="font-mono text-[13px] tracking-[0.8px] text-ink-mute">
              · {formatGregorianDDMMYYYY(ev.gregorian)} ·
            </span>
          </>
        )}
        {ev.location && (
          <span className="font-mono text-[12.5px] tracking-[0.8px] text-ink-mute">
            {ev.location}
          </span>
        )}
      </div>

      <FriezeRule label={t("introduction")} marginTop={0} marginBottom={14} />
      <p
        dir={isRTL ? "rtl" : "ltr"}
        className={cn(
          "mt-0 text-[20px] leading-[1.6] text-ink-soft text-pretty",
          lang === "ar" ? "font-arabic" : "font-serif italic tracking-[-0.2px]",
        )}
      >
        {localisedSummary}
      </p>

      {ev.imageUrl && (
        <figure className="mt-9 border-y border-rule py-5">
          <img
            src={ev.imageUrl}
            alt={localisedTitle}
            className="block h-[320px] w-full object-cover"
          />
          <figcaption className="mt-2.5 text-right font-mono text-[12px] uppercase tracking-[0.8px] text-ink-mute">
            {localisedTitle}
          </figcaption>
        </figure>
      )}

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
                {i === 0 && lang !== "ar" ? (
                  <span className="float-left mr-2.5 mt-1 font-serif text-[52px] font-medium leading-[0.85] text-ink">
                    {p.charAt(0)}
                  </span>
                ) : null}
                {i === 0 && lang !== "ar" ? p.slice(1) : p}
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
