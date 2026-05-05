import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { EightPointStar } from "@/components/design";
import { AccountLink } from "@/components/reader/AccountLink";
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
  const dateLine = `· ${today.gregorian.weekday} · ${today.hijri.day} ${today.hijri.month} ${today.hijri.year} ah ·`;

  return (
    <header className="border-b border-rule px-[clamp(20px,4vw,56px)] pt-4 pb-3 sm:pt-[26px] sm:pb-[18px]">
      {/* ─── Mobile (< sm): three stacked rows ─────────────────────── */}
      <div className="flex flex-col gap-3 sm:hidden">
        <div className="flex items-center justify-between gap-3">
          <Link to="/" className="flex items-center gap-2.5">
            <EightPointStar size={20} className="text-accent" strokeWidth={0.6} />
            <span className="font-mono text-[10.5px] uppercase tracking-[1.8px] text-ink">
              {t("app_name_short")}
            </span>
          </Link>
          <div className="flex items-center gap-2">
            <LanguageSwitcher />
            <button
              type="button"
              onClick={toggle}
              aria-label={dark ? t("light") : t("dark")}
              className="cursor-pointer border border-rule bg-transparent px-2.5 py-1.5 font-mono text-[12px] leading-none text-ink-soft"
            >
              {dark ? "☀" : "☾"}
            </button>
          </div>
        </div>

        <span className="text-center font-mono text-[10.5px] uppercase tracking-[2px] text-accent">
          {dateLine}
        </span>

        <nav className="flex flex-wrap justify-center gap-x-5 gap-y-1.5 font-mono text-[11.5px] uppercase tracking-[1.6px] text-ink-soft">
          <span className="text-ink">{t("today")}</span>
          <Link to="/recent" className="iotd-link">
            {t("recent")}
          </Link>
          <Link to="/observances" className="iotd-link">
            {t("observances")}
          </Link>
          <AccountLink />
        </nav>
      </div>

      {/* ─── Desktop (≥ sm): original 3-column grid ─────────────────── */}
      <div className="hidden grid-cols-[1fr_auto_1fr] items-center gap-6 sm:grid">
        <div className="flex items-center gap-3.5">
          <EightPointStar size={22} className="text-accent" strokeWidth={0.6} />
          <span className="font-mono text-[12.5px] uppercase tracking-[2px] text-ink">
            {t("app_name")}
          </span>
        </div>
        <span className="text-center font-mono text-[12px] uppercase tracking-[2.6px] text-accent">
          {dateLine}
        </span>
        <nav className="flex flex-wrap items-center justify-end gap-[18px] font-mono text-[12px] uppercase tracking-[1.6px] text-ink-soft">
          <span className="text-ink">{t("today")}</span>
          <Link to="/recent" className="iotd-link">
            {t("recent")}
          </Link>
          <Link to="/observances" className="iotd-link">
            {t("observances")}
          </Link>
          <AccountLink />
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
      </div>
    </header>
  );
}
