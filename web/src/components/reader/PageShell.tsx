import { Link } from "@tanstack/react-router";
import { useEffect, type ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { EightPointStar } from "@/components/design";
import { Footer } from "@/components/reader/Footer";
import { LanguageSwitcher } from "@/components/reader/LanguageSwitcher";
import { useTheme } from "@/providers/ThemeProvider";

interface Props {
  title: string;
  subtitle?: string;
  children: ReactNode;
}

export function PageShell({ title, subtitle, children }: Props) {
  const { t } = useTranslation();
  const { theme, toggle } = useTheme();
  const dark = theme === "dark";

  useEffect(() => {
    document.title = `${title} · Islamic On This Day`;
  }, [title]);

  return (
    <div className="min-h-full w-full bg-paper font-serif text-ink">
      <header className="grid grid-cols-[1fr_auto_1fr] items-center gap-6 border-b border-rule px-[clamp(20px,4vw,56px)] pt-[26px] pb-[18px]">
        <Link to="/" className="iotd-pick !flex items-center gap-3.5">
          <EightPointStar size={22} className="text-accent" strokeWidth={0.6} />
          <span className="font-mono text-[12.5px] uppercase tracking-[2px] text-ink">
            {t("back_to_today")}
          </span>
        </Link>
        <span className="text-center font-mono text-[12px] uppercase tracking-[2.6px] text-accent">
          · {title} ·
        </span>
        <nav className="flex flex-wrap items-center justify-end gap-[18px] font-mono text-[12px] uppercase tracking-[1.6px] text-ink-soft">
          <Link to="/recent" className="iotd-link">
            {t("recent")}
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

      {subtitle && (
        <div className="border-b border-rule-soft px-[clamp(20px,4vw,56px)] py-2.5 font-serif text-[16px] italic text-ink-soft">
          {subtitle}
        </div>
      )}

      <main className="mx-auto max-w-[880px] px-[clamp(20px,4vw,56px)] pt-8 pb-[60px]">
        {children}
      </main>

      <Footer />
    </div>
  );
}
