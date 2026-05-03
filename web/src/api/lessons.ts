// TanStack Query hook for the single-lesson detail endpoint using the generated SDK.

import { useQuery } from "@tanstack/react-query";
import { getLessonApiV1LessonsSlugGetOptions } from "@/api/generated/@tanstack/react-query.gen";

export function useLessonQuery(slug: string | undefined) {
  return useQuery({
    ...getLessonApiV1LessonsSlugGetOptions({ path: { slug: slug! } }),
    enabled: Boolean(slug),
  });
}
