import { useTranslation } from "react-i18next";

// Vite injects this from package.json at build time — see vite.config.ts.
const VERSION = import.meta.env.VITE_APP_VERSION ?? "dev";

export function Footer() {
  const { t } = useTranslation();
  return (
    <footer className="flex flex-wrap items-center justify-between gap-3 border-t border-rule px-[clamp(20px,4vw,56px)] py-5 font-mono text-[12px] uppercase tracking-[1.2px] text-ink-mute">
      <span>{t("classical_record_tagline")}</span>
      <span>
        {VERSION} · 1447 ah {t("build_label")}
      </span>
    </footer>
  );
}
