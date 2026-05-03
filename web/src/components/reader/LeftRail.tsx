import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import type { ObservanceRef, TodayResponse } from "@/api/generated/types.gen";

interface Props {
  today: TodayResponse["today"];
  observance: ObservanceRef | null;
}

export function LeftRail({ today, observance }: Props) {
  const { t } = useTranslation();
  return (
    <aside className="iotd-rail-left min-h-[600px] border-r border-rule pt-10 pb-10 pr-7 pl-[clamp(20px,4vw,56px)]">
      <FriezeRule marginTop={0} marginBottom={20} rosetteOnly />
      <div className="text-center">
        <div className="font-mono text-[11px] uppercase tracking-[1.8px] text-accent">
          {t("today")}
        </div>
        <div className="mt-4 font-serif text-[64px] font-medium leading-[0.85] tracking-[-2px] text-ink">
          {today.hijri.day}
        </div>
        <div className="mt-8 font-serif text-[18px] italic leading-[1.1] text-ink">
          {today.hijri.month}
        </div>
        <div className="mt-1.5 font-mono text-[12px] uppercase tracking-[0.8px] text-ink-mute">
          {today.hijri.year} AH
        </div>
        {today.hijri.monthShort && (
          <div className="mt-[18px] font-arabic text-[24px] text-ink-soft" dir="rtl">
            {today.hijri.monthShort}
          </div>
        )}
      </div>

      <FriezeRule marginTop={26} marginBottom={20} rosetteOnly />
      <div className="text-center">
        <div className="font-mono text-[11px] uppercase tracking-[1.8px] text-ink-mute">
          {t("gregorian")}
        </div>
        <div className="mt-2.5 font-serif text-[56px] font-medium leading-none tracking-[-1.4px] text-ink">
          {today.gregorian.day}
        </div>
        <div className="mt-3.5 font-serif text-[18px] font-medium tracking-[-0.2px] text-ink">
          {today.gregorian.month}
        </div>
        <div className="mt-1 font-mono text-[12px] uppercase tracking-[0.8px] text-ink-mute">
          {today.gregorian.year}
        </div>
      </div>

      {observance && (
        <>
          <FriezeRule label={t("observance_label")} marginTop={32} marginBottom={14} />
          <div>
            <div className="font-serif text-[16px] font-medium leading-[1.2] tracking-[-0.2px] text-ink">
              {observance.name}
            </div>
            {observance.summary && (
              <p className="mt-2 font-serif text-[13.5px] italic leading-[1.5] text-ink-soft text-pretty">
                {observance.summary}
              </p>
            )}
          </div>
        </>
      )}
    </aside>
  );
}
