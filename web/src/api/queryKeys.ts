// Centralised query-key map. Lets every callsite invalidate or prefetch
// without re-deriving a hey-api options object — saves us from drifting
// queryKey shapes between fetch and invalidate sites.
//
// (Today only `/today` and `/recent` make sense to invalidate, but exposing
// the map up-front keeps the surface uniform as more endpoints land.)

import {
  getEventApiV1EventsSlugGetQueryKey,
  getLessonApiV1LessonsSlugGetQueryKey,
  getObservanceApiV1ObservancesSlugGetQueryKey,
  getPersonApiV1PeopleSlugGetQueryKey,
  getRecentApiV1RecentGetQueryKey,
  getTodayApiV1TodayGetQueryKey,
  listEventsApiV1EventsGetQueryKey,
  listLessonsApiV1LessonsGetQueryKey,
  listObservancesApiV1ObservancesGetQueryKey,
} from "@/api/generated/@tanstack/react-query.gen";

export const queryKeys = {
  today: () => getTodayApiV1TodayGetQueryKey(),
  recent: (days?: number) =>
    getRecentApiV1RecentGetQueryKey(days ? { query: { days } } : undefined),

  events: {
    list: (
      query?: Parameters<typeof listEventsApiV1EventsGetQueryKey>[0] extends infer T
        ? T extends { query?: infer Q }
          ? Q
          : never
        : never,
    ) => listEventsApiV1EventsGetQueryKey(query ? { query } : undefined),
    bySlug: (slug: string) => getEventApiV1EventsSlugGetQueryKey({ path: { slug } }),
  },
  lessons: {
    list: () => listLessonsApiV1LessonsGetQueryKey(),
    bySlug: (slug: string) => getLessonApiV1LessonsSlugGetQueryKey({ path: { slug } }),
  },
  observances: {
    list: () => listObservancesApiV1ObservancesGetQueryKey(),
    bySlug: (slug: string) => getObservanceApiV1ObservancesSlugGetQueryKey({ path: { slug } }),
  },
  people: {
    bySlug: (slug: string) => getPersonApiV1PeopleSlugGetQueryKey({ path: { slug } }),
  },
} as const;
