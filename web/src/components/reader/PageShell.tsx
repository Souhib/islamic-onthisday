import { Link } from "@tanstack/react-router";
import { useEffect, type ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { useAuth } from "@/auth/AuthProvider";
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
  const { isAuthenticated, isInitialised } = useAuth();
  const dark = theme === "dark";
  const accountLink = isInitialised
    ? isAuthenticated
      ? { to: "/saves" as const, label: t("auth.saves") }
      : { to: "/sign-in" as const, label: t("auth.sign_in") }
    : null;

  useEffect(() => {
    document.title = `${title} · Islamic On This Day`;
  }, [title]);

  return (
    <div className="min-h-full w-full bg-paper font-serif text-ink">
      <header className="border-b border-rule px-[clamp(20px,4vw,56px)] pt-4 pb-3 sm:pt-[26px] sm:pb-[18px]">
        {/* ─── Mobile (< sm): three stacked rows ────────────────────── */}
        <div className="flex flex-col gap-3 sm:hidden">
          <div className="flex items-center justify-between gap-3">
            <Link to="/" className="iotd-pick !flex items-center gap-2.5">
              <EightPointStar size={20} className="text-accent" strokeWidth={0.6} />
              <span className="font-mono text-[10.5px] uppercase tracking-[1.8px] text-ink">
                {t("back_to_today")}
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
            · {title} ·
          </span>

          <nav className="flex justify-center gap-5 font-mono text-[11.5px] uppercase tracking-[1.6px] text-ink-soft">
            <Link to="/recent" className="iotd-link">
              {t("recent")}
            </Link>
            <Link to="/observances" className="iotd-link">
              {t("observances")}
            </Link>
            {accountLink && (
              <Link to={accountLink.to} className="iotd-link">
                {accountLink.label}
              </Link>
            )}
          </nav>
        </div>

        {/* ─── Desktop (≥ sm): original 3-column grid ───────────────── */}
        <div className="hidden grid-cols-[1fr_auto_1fr] items-center gap-6 sm:grid">
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
            {accountLink && (
              <Link to={accountLink.to} className="iotd-link">
                {accountLink.label}
              </Link>
            )}
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
