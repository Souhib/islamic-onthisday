import { useTranslation } from "react-i18next";
import { SUPPORTED_LANGUAGES, type Language } from "@/i18n";
import { cn } from "@/lib/utils";

const LABEL: Record<Language, string> = { en: "EN", fr: "FR", ar: "ع" };

export function LanguageSwitcher() {
  const { i18n, t } = useTranslation();
  const current = (i18n.language?.split("-")[0] ?? "en") as Language;
  return (
    <div
      role="group"
      aria-label={t("language", "Language")}
      className="inline-flex overflow-hidden border border-rule"
    >
      {SUPPORTED_LANGUAGES.map((l, i) => {
        const active = current === l;
        return (
          <button
            key={l}
            type="button"
            onClick={() => void i18n.changeLanguage(l)}
            aria-pressed={active}
            className={cn(
              "cursor-pointer border-0 px-2.5 py-1.5 font-mono text-[12px] uppercase tracking-[1.4px]",
              i > 0 && "border-l border-rule",
              active ? "bg-paper-hi text-ink" : "bg-transparent text-ink-mute",
            )}
          >
            {LABEL[l]}
          </button>
        );
      })}
    </div>
  );
}
