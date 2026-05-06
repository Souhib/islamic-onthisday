// Date formatting helpers for the project's historical Gregorian dates.
//
// The backend ships ``gregorian`` as ISO ``YYYY-MM-DD`` (e.g. "1030-05-06")
// for any event with day-precision; older events with year-only attestation
// don't render this row at all. The reading surface shows the date twice:
//   - long localised form ("5 May 1030", "5 mai 1030", "٥ مايو ١٠٣٠")
//   - numeric ``DD-MM-YYYY`` for quick scanning
//
// Both helpers are pure and accept the ISO string the API returns.

import type { Language } from "@/providers/LanguageProvider";

const _LOCALE_BCP47: Record<Language, string> = {
  en: "en-GB",
  fr: "fr-FR",
  ar: "ar-SA",
};

function _parseISO(iso: string): Date | null {
  const match = iso.match(/^(\d{1,4})-(\d{2})-(\d{2})$/);
  if (!match) return null;
  const [, y, m, d] = match;
  // ``Date.UTC`` reads the year literally for values >= 100 (and we never
  // see a Gregorian < 622 in this dataset). Building in UTC sidesteps the
  // browser timezone shifting "1030-05-06" back a day in TZ < UTC zones.
  return new Date(Date.UTC(Number(y), Number(m) - 1, Number(d)));
}

/**
 * Render an ISO ``YYYY-MM-DD`` as a localised long-form date —
 * ``5 May 1030`` (en), ``5 mai 1030`` (fr), Arabic numerals + month name (ar).
 * Returns the input unchanged if parsing fails.
 */
export function formatGregorianLong(iso: string, lang: Language): string {
  const date = _parseISO(iso);
  if (date === null) return iso;
  return new Intl.DateTimeFormat(_LOCALE_BCP47[lang] ?? "en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(date);
}

/**
 * Render an ISO ``YYYY-MM-DD`` as ``DD-MM-YYYY``. Pure string transform —
 * no locale coupling, the format is identical in every language.
 */
export function formatGregorianDDMMYYYY(iso: string): string {
  const match = iso.match(/^(\d{1,4})-(\d{2})-(\d{2})$/);
  if (!match) return iso;
  const [, y, m, d] = match;
  // Pad the year so a 3-digit year (rare, ~year 622-999 of the Hijri era)
  // still reads as four digits.
  return `${d}-${m}-${y.padStart(4, "0")}`;
}
