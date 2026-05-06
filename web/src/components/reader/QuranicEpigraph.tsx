import { useTranslation } from "react-i18next";
import { FriezeRule } from "@/components/design";
import { useLanguage } from "@/providers/LanguageProvider";
import { pickVerse, useQuranExtracts, type QuranicVerse } from "@/api/quranExtracts";
import { firstQuranKey } from "@/lib/refs";

interface Props {
  // The freeform ``quran_refs`` of the day's headline. When null/empty
  // the component falls back to Yūsuf 12:111 — the project's epigraph,
  // not a random rotation.
  quranRefs?: string | null;
}

// A centered Qur'anic citation rendered above the footer. Trilingual:
// vocalised Arabic on top, locale translation in the middle, surah +
// ayah in mono caps below. Tied to the day's event when possible
// (``firstQuranKey`` of the event's ``quran_refs``); otherwise shows the
// fixed editorial fallback (Yūsuf 12:111 — *"there is a lesson for
// those of understanding"*).
export function QuranicEpigraph({ quranRefs }: Props) {
  const { t } = useTranslation();
  const { lang } = useLanguage();
  const { data: extracts } = useQuranExtracts();

  const key = firstQuranKey(quranRefs);
  const verse: QuranicVerse | null = pickVerse(extracts, key);
  if (!verse) return null;

  const translation = lang === "ar" ? null : lang === "fr" ? verse.fr : verse.en;
  const surahLabel =
    lang === "ar"
      ? `${verse.surahNameAr} · ${verse.surahNumber}:${verse.ayahNumber}`
      : `${t("surah_prefix")} ${verse.surahNameEn} · ${verse.surahNumber}:${verse.ayahNumber}`;

  return (
    <section className="border-t border-rule px-[clamp(20px,4vw,56px)] py-12">
      <div className="mx-auto max-w-[760px]">
        <FriezeRule rosetteOnly marginTop={0} marginBottom={28} />

        <p
          dir="rtl"
          lang="ar"
          className="text-center font-arabic text-[clamp(22px,2.6vw,30px)] leading-[1.9] text-ink"
        >
          {verse.ar}
        </p>

        {translation && (
          <p
            className="mt-7 text-center font-serif text-[clamp(16px,1.6vw,19px)] italic leading-[1.55] text-ink-soft text-pretty"
            lang={lang}
          >
            “{translation}”
          </p>
        )}

        <div className="mt-7 text-center font-mono text-[12px] uppercase tracking-[2px] text-ink-mute">
          {surahLabel}
        </div>

        <FriezeRule rosetteOnly marginTop={28} marginBottom={0} />
      </div>
    </section>
  );
}
