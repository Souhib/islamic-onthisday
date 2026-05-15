// Pipeline-emitted depth stat for the footer signal. Same static-asset
// posture as `sitemap.xml` / `feed.xml` — written by the pipeline,
// served by the FE host, fetched once on mount.
//
// **Cache strategy.** We default to the browser's normal HTTP cache
// (``cache: "default"``) so the server's ``Cache-Control: max-age=3600``
// is respected. An earlier ``"force-cache"`` directive made the browser
// return *any* cached copy — fresh or stale — forever, which left
// returning visitors stuck on the previous build's counter for days
// after a redeploy. Default-cache + revalidation gives us at-most-1h
// staleness, which is fine for a counter that moves weekly at most.

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
    const res = await fetch("/dataset-meta.json", { cache: "default" });
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
