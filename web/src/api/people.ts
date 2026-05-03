// TanStack Query hook for the single-person detail endpoint using the generated SDK.

import { useQuery } from "@tanstack/react-query";
import { getPersonApiV1PeopleSlugGetOptions } from "@/api/generated/@tanstack/react-query.gen";

export function usePersonQuery(slug: string | undefined) {
  return useQuery({
    ...getPersonApiV1PeopleSlugGetOptions({ path: { slug: slug! } }),
    enabled: Boolean(slug),
  });
}
