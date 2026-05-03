// TanStack Query hook for the Today endpoint using the generated SDK.
//
// Note: the route deliberately exposes no date parameter — the daily-ritual
// constraint of the project. If you need to read a specific event/lesson
// from a past day, hit `/events/{slug}` directly via `useEventQuery` etc.

import { useQuery } from "@tanstack/react-query";
import { getTodayApiV1TodayGetOptions } from "@/api/generated/@tanstack/react-query.gen";

export function useTodayQuery() {
  return useQuery(getTodayApiV1TodayGetOptions());
}
