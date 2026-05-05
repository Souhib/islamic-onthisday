// Shared chrome for the *-detail routes (events, lessons, observances,
// people). Three-column grid: back-to-today on the left, an eyebrow in
// the centre, and the theme toggle on the right. Pulled out so detail
// pages stop reimplementing the same 70 lines of layout.

import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { EightPointStar } from "@/components/design";
import { AccountLink } from "@/components/reader/AccountLink";
import { useTheme } from "@/providers/ThemeProvider";

interface Props {
  /** The eyebrow centre-piece — already-localised text, no further i18n. */
  eyebrow: string;
}

export function DetailHeader({ eyebrow }: Props) {
  const { t } = useTranslation();
  const { theme, toggle } = useTheme();
  const dark = theme === "dark";

  return (
    <header className="grid grid-cols-[1fr_auto_1fr] items-center gap-6 border-b border-rule px-[clamp(20px,4vw,56px)] pt-[26px] pb-[18px]">
      <Link to="/" className="iotd-pick !flex items-center gap-3.5">
        <EightPointStar size={22} className="text-accent" strokeWidth={0.6} />
        <span className="font-mono text-[12.5px] uppercase tracking-[2px] text-ink">
          {t("back_to_today")}
        </span>
      </Link>
      <span className="text-center font-mono text-[12px] uppercase tracking-[2.6px] text-accent">
        {eyebrow}
      </span>
      <div className="flex items-center gap-4 justify-self-end font-mono text-[11.5px] uppercase tracking-[1.6px] text-ink-soft">
        <AccountLink />
        <button
          type="button"
          onClick={toggle}
          aria-label={t("dark")}
          className="cursor-pointer border border-rule bg-transparent px-3 py-1.5 font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft"
        >
          {dark ? t("light") : t("dark")}
        </button>
      </div>
    </header>
  );
}
