import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { EightPointStar } from "@/components/design";
import { LanguageSwitcher } from "@/components/reader/LanguageSwitcher";
import { useTheme } from "@/providers/ThemeProvider";
import type { TodayResponse } from "@/api/generated/types.gen";

interface Props {
  today: TodayResponse["today"];
}

export function Masthead({ today }: Props) {
  const { t } = useTranslation();
  const { theme, toggle } = useTheme();
  const dark = theme === "dark";
  return (
    <header className="grid grid-cols-[1fr_auto_1fr] items-center gap-6 border-b border-rule px-[clamp(20px,4vw,56px)] pt-[26px] pb-[18px]">
      <div className="flex items-center gap-3.5">
        <EightPointStar size={22} className="text-accent" strokeWidth={0.6} />
        <span className="font-mono text-[12.5px] uppercase tracking-[2px] text-ink">
          {t("app_name")}
        </span>
      </div>
      <span className="text-center font-mono text-[12px] uppercase tracking-[2.6px] text-accent">
        · {today.gregorian.weekday} · {today.hijri.day} {today.hijri.month} {today.hijri.year} ah ·
      </span>
      <nav className="flex flex-wrap items-center justify-end gap-[18px] font-mono text-[12px] uppercase tracking-[1.6px] text-ink-soft">
        <span className="text-ink">{t("today")}</span>
        <Link to="/browse" className="iotd-link">
          {t("browse")}
        </Link>
        <Link to="/search" className="iotd-link">
          {t("search")}
        </Link>
        <Link to="/observances" className="iotd-link">
          {t("observances")}
        </Link>
        <LanguageSwitcher />
        <button
          type="button"
          onClick={toggle}
          aria-label={t("dark")}
          className="cursor-pointer border border-rule bg-transparent px-3 py-1.5 font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft"
        >
          {dark ? t("light") : t("dark")}
        </button>
      </nav>
    </header>
  );
}
