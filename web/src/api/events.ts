// TanStack Query hook for the single-event detail endpoint using the generated SDK.

import { useQuery } from "@tanstack/react-query";
import { getEventApiV1EventsSlugGetOptions } from "@/api/generated/@tanstack/react-query.gen";

export function useEventQuery(slug: string | undefined) {
  return useQuery({
    ...getEventApiV1EventsSlugGetOptions({ path: { slug: slug! } }),
    enabled: Boolean(slug),
  });
}
