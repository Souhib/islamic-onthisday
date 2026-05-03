// Trilingual language preference (en / fr / ar). Persistence + detection live
// in i18next (see `@/i18n`); this provider just keeps the React tree in sync
// with i18n.language and exposes the small helpers (`pickLocalised`, `useT`,
// `useLanguage`) that components depend on.

import { useEffect, useState, type ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { SUPPORTED_LANGUAGES, type Language } from "@/i18n";

interface LanguageContextValue {
  lang: Language;
  setLang: (l: Language) => void;
  isRTL: boolean;
}

function isLanguage(value: unknown): value is Language {
  return typeof value === "string" && (SUPPORTED_LANGUAGES as readonly string[]).includes(value);
}

function resolveLang(raw: string | undefined): Language {
  const head = raw?.split("-")[0]?.toLowerCase();
  return isLanguage(head) ? head : "en";
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const { i18n } = useTranslation();
  const [lang, setLangState] = useState<Language>(() => resolveLang(i18n.language));

  useEffect(() => {
    const handleChange = (next: string) => setLangState(resolveLang(next));
    i18n.on("languageChanged", handleChange);
    return () => {
      i18n.off("languageChanged", handleChange);
    };
  }, [i18n]);

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
  }, [lang]);

  const setLang = (next: Language) => {
    void i18n.changeLanguage(next);
  };

  return (
    <LanguageContext.Provider value={{ lang, setLang, isRTL: lang === "ar" }}>
      {children}
    </LanguageContext.Provider>
  );
}

import { createContext, useContext } from "react";

const LanguageContext = createContext<LanguageContextValue | null>(null);

export function useLanguage(): LanguageContextValue {
  const ctx = useContext(LanguageContext);
  if (!ctx) throw new Error("useLanguage must be used inside <LanguageProvider>");
  return ctx;
}

/**
 * Pick the field for the current language with a fallback chain.
 *
 * Strategy: requested lang → English → undefined.
 *
 * For example, when `lang === "fr"` and a French translation hasn't landed
 * yet for an event, the user sees the English version rather than an empty
 * field.
 */
export function pickLocalised(
  values: { en: string | null; fr?: string | null; ar?: string | null },
  lang: Language,
): string | undefined {
  if (lang === "fr" && values.fr) return values.fr;
  if (lang === "ar" && values.ar) return values.ar;
  return values.en ?? undefined;
}

export function pickLocalisedList(
  values: { en: string[]; fr?: string[] | null; ar?: string[] | null },
  lang: Language,
): string[] {
  if (lang === "fr" && values.fr && values.fr.length > 0) return values.fr;
  if (lang === "ar" && values.ar && values.ar.length > 0) return values.ar;
  return values.en;
}

/**
 * Thin wrapper around react-i18next's `useTranslation().t` so legacy
 * callsites (`const T = useT(); T("foo")`) keep working during the
 * migration. New code should prefer `const { t } = useTranslation()`
 * directly — interpolation, plurals, and `Trans` come along for free.
 */
export function useT() {
  const { t } = useTranslation();
  return (key: string): string => t(key);
}

export type { Language };
