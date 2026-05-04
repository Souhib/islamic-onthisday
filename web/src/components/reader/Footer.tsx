import { useTranslation } from "react-i18next";
import { useDatasetMeta } from "@/api/datasetMeta";

// Vite injects this from package.json at build time — see vite.config.ts.
const VERSION = import.meta.env.VITE_APP_VERSION ?? "dev";
const TOTAL_GREGORIAN_DAYS = 366;

export function Footer() {
  const { t, i18n } = useTranslation();
  const { data: meta } = useDatasetMeta();

  const fmt = new Intl.NumberFormat(i18n.language === "ar" ? "ar" : i18n.language || "en");
  const stat = meta
    ? [
        t("dataset_depth_events", {
          count: meta.eventCount,
          formatted: fmt.format(meta.eventCount),
        }),
        t("dataset_depth_sacred_days", { count: meta.observanceCount }),
        t("dataset_depth_days_covered", {
          covered: fmt.format(meta.daysWithHeadline),
          total: fmt.format(TOTAL_GREGORIAN_DAYS),
        }),
      ].join(" · ")
    : null;

  return (
    <footer className="flex flex-wrap items-center justify-between gap-x-6 gap-y-2 border-t border-rule px-[clamp(20px,4vw,56px)] py-5 font-mono text-[12px] uppercase tracking-[1.2px] text-ink-mute">
      {stat && <span className="text-ink-soft">{stat}</span>}
      <span className="ms-auto flex flex-wrap items-center gap-x-3 gap-y-1">
        <span className="hidden sm:inline">{t("classical_record_tagline")}</span>
        <span>
          {VERSION} · 1447 ah {t("build_label")}
        </span>
      </span>
    </footer>
  );
}
