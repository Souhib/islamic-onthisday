// Pipeline-emitted depth stat for the footer signal. Same static-asset
// posture as `sitemap.xml` / `feed.xml` — written by the pipeline,
// served by the FE host, fetched once on mount, treated as a constant
// after that. If the file is absent (fresh clone before first build),
// the hook resolves to `null` and the footer skips the stat.

import { useQuery } from "@tanstack/react-query";

export interface DatasetMeta {
  eventCount: number;
  observanceCount: number;
  personCount: number;
  daysWithHeadline: number;
  generatedAt: string;
}

interface RawDatasetMeta {
  event_count: number;
  observance_count: number;
  person_count: number;
  days_with_headline: number;
  generated_at: string;
}

async function fetchDatasetMeta(): Promise<DatasetMeta | null> {
  try {
    const res = await fetch("/dataset-meta.json", { cache: "force-cache" });
    if (!res.ok) return null;
    const raw = (await res.json()) as RawDatasetMeta;
    return {
      eventCount: raw.event_count,
      observanceCount: raw.observance_count,
      personCount: raw.person_count,
      daysWithHeadline: raw.days_with_headline,
      generatedAt: raw.generated_at,
    };
  } catch {
    return null;
  }
}

export function useDatasetMeta() {
  return useQuery({
    queryKey: ["dataset-meta"],
    queryFn: fetchDatasetMeta,
    staleTime: Infinity,
    gcTime: Infinity,
    retry: false,
  });
}
