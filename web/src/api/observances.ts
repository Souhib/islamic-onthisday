// TanStack Query hooks for observances using the generated SDK.

import { useQuery } from "@tanstack/react-query";
import {
  listObservancesApiV1ObservancesGetOptions,
  getObservanceApiV1ObservancesSlugGetOptions,
} from "@/api/generated/@tanstack/react-query.gen";

export function useObservancesQuery() {
  return useQuery(listObservancesApiV1ObservancesGetOptions());
}

export function useObservanceQuery(slug: string | undefined) {
  return useQuery({
    ...getObservanceApiV1ObservancesSlugGetOptions({ path: { slug: slug! } }),
    enabled: Boolean(slug),
  });
}
