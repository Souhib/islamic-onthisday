// Pipeline-emitted trilingual ayah cache. Same static-asset posture as
// `dataset-meta.json` — the data-pipeline build fetches every cited
// verse from alquran.cloud once, writes the JSON, and the FE
// lazy-loads it on mount. If the file is absent (fresh clone before
// first build), the hook resolves to `null` and the epigraph is
// hidden.

import { useQuery } from "@tanstack/react-query";

export interface QuranicVerse {
  ar: string;
  en: string;
  fr: string;
  surahNumber: number;
  ayahNumber: number;
  surahNameAr: string;
  surahNameEn: string;
}

export interface QuranExtracts {
  fallback: string;
  verses: Record<string, QuranicVerse>;
}

async function fetchQuranExtracts(): Promise<QuranExtracts | null> {
  try {
    const res = await fetch("/quran-extracts.json", { cache: "force-cache" });
    if (!res.ok) return null;
    return (await res.json()) as QuranExtracts;
  } catch {
    return null;
  }
}

export function useQuranExtracts() {
  return useQuery({
    queryKey: ["quran-extracts"],
    queryFn: fetchQuranExtracts,
    staleTime: Infinity,
    gcTime: Infinity,
    retry: false,
  });
}

/**
 * Pick a verse from the cached map. When ``key`` is missing or absent
 * from the dataset, falls back to the file's declared fallback verse
 * (Yūsuf 12:111 — the project's editorial epigraph).
 */
export function pickVerse(
  extracts: QuranExtracts | null | undefined,
  key: string | null | undefined,
): QuranicVerse | null {
  if (!extracts) return null;
  if (key && extracts.verses[key]) return extracts.verses[key];
  return extracts.verses[extracts.fallback] ?? null;
}
