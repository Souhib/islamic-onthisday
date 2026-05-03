// TanStack Query hooks for /api/v1/events list and search using the generated SDK.

import { useQuery } from "@tanstack/react-query";
import { listEventsApiV1EventsGetOptions } from "@/api/generated/@tanstack/react-query.gen";

export interface ListFilters {
  era?: string;
  category?: string;
  hijriMonth?: number;
  importance?: "major" | "notable" | "minor";
  q?: string;
  limit?: number;
  offset?: number;
}

export function useEventListQuery(filters: ListFilters) {
  return useQuery(
    listEventsApiV1EventsGetOptions({
      query: {
        era: filters.era,
        category: filters.category,
        hijri_month: filters.hijriMonth,
        importance: filters.importance,
        q: filters.q,
        limit: filters.limit,
        offset: filters.offset,
      },
    }),
  );
}

export function useSearchQuery(q: string) {
  const trimmed = q.trim();
  return useQuery({
    ...listEventsApiV1EventsGetOptions({
      query: { q: trimmed, limit: 20 },
    }),
    // Backend rejects q with min_length=2; don't make a doomed call.
    enabled: trimmed.length >= 2,
  });
}
