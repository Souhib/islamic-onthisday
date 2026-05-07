// i18next bootstrap. Locales are JSON files under ./locales and are loaded
// lazily — only the active language ships in the initial bundle.
//
// Detection order: localStorage (so a previous explicit choice wins), then
// the navigator language, then the html `lang` attribute. We default to
// English when nothing matches.

import i18n from "i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import resourcesToBackend from "i18next-resources-to-backend";
import { initReactI18next } from "react-i18next";

export const SUPPORTED_LANGUAGES = ["en", "fr", "ar"] as const;
export type Language = (typeof SUPPORTED_LANGUAGES)[number];

void i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .use(resourcesToBackend((language: string) => import(`./locales/${language}.json`)))
  .init({
    fallbackLng: "en",
    supportedLngs: SUPPORTED_LANGUAGES,
    interpolation: { escapeValue: false }, // React already escapes
    detection: {
      order: ["localStorage", "navigator", "htmlTag"],
      caches: ["localStorage"],
      lookupLocalStorage: "thaqafa-lang",
    },
  });

export default i18n;
