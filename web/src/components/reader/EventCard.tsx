import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { VerificationChip, isVerificationKind, type VerificationKind } from "@/components/design";
import { DisputeBadge, type DisputeAbout } from "@/components/disputed/DisputeBadge";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import type { EventSummary } from "@/api/generated/types.gen";
import { cn } from "@/lib/utils";

interface Props {
  item: EventSummary;
  showVerification?: boolean;
}

export function EventCard({ item, showVerification = true }: Props) {
  const { t } = useTranslation();
  const { lang, isRTL } = useLanguage();
  const localisedTitle = pickLocalised(
    { en: item.title, fr: item.titleFr, ar: item.titleAr },
    lang,
  );
  const verificationKind: VerificationKind = isVerificationKind(item.verificationStatus)
    ? item.verificationStatus
    : "unverified";

  return (
    <Link
      to="/events/$slug"
      params={{ slug: item.id }}
      className="iotd-link block border-b border-rule-soft py-4"
    >
      <div className="flex flex-wrap items-baseline gap-3">
        <span className="font-mono text-[11px] uppercase tracking-[1.4px] text-accent">
          {item.era ? t(item.era, item.era) : "—"}
        </span>
        <span className="font-mono text-[11px] uppercase tracking-[0.6px] text-ink-mute">
          {t(item.importance, item.importance)}
        </span>
        {showVerification && (
          <VerificationChip kind={verificationKind} size="xs" label={t(verificationKind)} />
        )}
        {item.disputed && <DisputeBadge disputeAbout={item.disputeAbout as DisputeAbout} />}
      </div>
      <div
        dir={isRTL ? "rtl" : "ltr"}
        className={cn(
          "mt-1.5 text-[18px] font-medium text-ink text-pretty",
          lang === "ar"
            ? "font-arabic leading-[1.5]"
            : "font-serif leading-[1.15] tracking-[-0.3px]",
        )}
      >
        {localisedTitle}
      </div>
      <div className="mt-1.5 flex gap-4 font-mono text-[12px] tracking-[0.4px] text-ink-mute">
        {item.hijri && <span className="font-serif text-[13px] italic">{item.hijri}</span>}
        {item.gregorian && <span>{item.gregorian}</span>}
      </div>
    </Link>
  );
}
