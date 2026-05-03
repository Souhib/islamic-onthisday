import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useTodayQuery } from "@/api/today";
import { useEventQuery } from "@/api/events";
import { useLessonQuery } from "@/api/lessons";
import { DisputedDrawer } from "@/components/disputed/DisputedDrawer";
import { Footer } from "@/components/reader/Footer";
import { LeftRail } from "@/components/reader/LeftRail";
import { LessonReader } from "@/components/reader/LessonReader";
import { Main } from "@/components/reader/Main";
import { Masthead } from "@/components/reader/Masthead";
import { RightRail } from "@/components/reader/RightRail";
import { TodayBottomSection } from "@/components/reader/TodayBottomSection";
import { Empty } from "@/components/ui/Empty";
import { Loading } from "@/components/ui/Loading";
import { trackDisputeOpened } from "@/lib/analytics";
import { pickLocalised, useLanguage } from "@/providers/LanguageProvider";
import { cn } from "@/lib/utils";
import type {
  EventDetail,
  EventSummary,
  LessonDetail,
  LessonSummary,
} from "@/api/generated/types.gen";

function isEventDetail(headline: unknown): headline is EventDetail {
  return headline !== null && typeof headline === "object" && !("kind" in headline);
}

export interface TodaySearch {
  event?: string;
  lesson?: string;
}

function TodayPage() {
  const { t } = useTranslation();
  const { lang } = useLanguage();
  const navigate = useNavigate({ from: "/" });
  const search = Route.useSearch();

  const todayQuery = useTodayQuery();
  const [drawerOpen, setDrawerOpen] = useState(false);

  const data = todayQuery.data;
  const calendar = data?.today;
  const headline = data?.headline;
  const secondaries = data?.secondary ?? [];
  const observance = data?.observance ?? null;

  useEffect(() => {
    if (headline) {
      const title = pickLocalised(
        { en: headline.title, fr: headline.titleFr, ar: headline.titleAr },
        lang,
      );
      document.title = `${title} · Islamic On This Day`;
    } else {
      document.title = "Islamic On This Day";
    }
  }, [headline, lang]);

  const activeSlug = search.event ?? search.lesson ?? null;
  const isActiveEvent = Boolean(search.event);
  const isActiveLesson = Boolean(search.lesson);
  const headlineId = headline?.id ?? null;
  const activeIsHeadline = activeSlug === headlineId;
  const headlineIsEvent = isEventDetail(headline);

  const activeEventQuery = useEventQuery(
    isActiveEvent && !activeIsHeadline && activeSlug ? activeSlug : undefined,
  );
  const activeLessonQuery = useLessonQuery(
    isActiveLesson && !activeIsHeadline && activeSlug ? activeSlug : undefined,
  );

  const mainItem = useMemo(() => {
    if (!activeSlug || activeIsHeadline) return headline ?? null;
    if (isActiveEvent && activeEventQuery.data) return activeEventQuery.data;
    if (isActiveLesson && activeLessonQuery.data) return activeLessonQuery.data;
    return null;
  }, [
    activeSlug,
    activeIsHeadline,
    headline,
    isActiveEvent,
    activeEventQuery.data,
    isActiveLesson,
    activeLessonQuery.data,
  ]);

  const mainIsEvent = isEventDetail(mainItem);
  const mainIsLesson = mainItem !== null && !mainIsEvent;

  const bottomItems = useMemo(() => {
    const items: Array<{ item: EventSummary | LessonSummary; isHeadline: boolean }> = [];
    if (headline) {
      const summary = headlineIsEvent
        ? ({
            id: headline.id,
            title: headline.title,
            titleAr: headline.titleAr,
            titleFr: headline.titleFr,
            hijri: headline.hijri,
            gregorian: headline.gregorian,
            era: headline.era,
            importance: headline.importance,
            verificationStatus: headline.verificationStatus,
            disputed: headline.disputed,
            disputeAbout: headline.disputeAbout,
          } as EventSummary)
        : ({
            kind: "lesson",
            id: headline.id,
            title: headline.title,
            titleAr: headline.titleAr,
            titleFr: headline.titleFr,
            category: (headline as LessonDetail).category,
            reference: (headline as LessonDetail).reference,
          } as LessonSummary);
      items.push({ item: summary, isHeadline: true });
    }
    for (const s of secondaries) {
      items.push({ item: s, isHeadline: false });
    }
    return items;
  }, [headline, headlineIsEvent, secondaries]);

  const handlePickItem = (id: string, isLessonItem: boolean) => {
    if (id === activeSlug) {
      navigate({ search: {} });
    } else if (isLessonItem) {
      navigate({ search: { lesson: id } });
    } else {
      navigate({ search: { event: id } });
    }
  };

  return (
    <div className="relative min-h-full w-full bg-paper font-serif text-ink">
      {calendar && <Masthead today={calendar} />}
      <SourceBadge
        live={todayQuery.isSuccess && !!headline}
        apiReachable={todayQuery.isSuccess}
        pending={todayQuery.isPending}
      />

      <div className="iotd-grid mx-auto">
        {calendar && <LeftRail today={calendar} observance={observance} />}
        <div className="iotd-main">
          {todayQuery.isPending && <Loading labelKey="loading" />}
          {todayQuery.isError && <Empty message={t("search_error")} />}
          {todayQuery.isSuccess && !mainItem && <Empty message={t("not_found")} />}
          {mainIsEvent && mainItem && (
            <Main
              ev={mainItem as EventDetail}
              onOpenDispute={() => {
                trackDisputeOpened((mainItem as EventDetail).id);
                setDrawerOpen(true);
              }}
            />
          )}
          {mainIsLesson && mainItem && <LessonReader lesson={mainItem as LessonDetail} />}
        </div>
        <RightRail item={mainItem} observance={observance} />
      </div>

      {bottomItems.length > 0 && <TodayBottomSection items={bottomItems} onPick={handlePickItem} />}

      <Footer />

      {drawerOpen && mainIsEvent && mainItem && (
        <DisputedDrawer event={mainItem as EventDetail} onClose={() => setDrawerOpen(false)} />
      )}
    </div>
  );
}

interface SourceBadgeProps {
  live: boolean;
  apiReachable: boolean;
  pending: boolean;
}

function SourceBadge({ live, apiReachable, pending }: SourceBadgeProps) {
  // Dev affordance only — hidden in production builds.
  if (import.meta.env.PROD) return null;
  const label = pending
    ? "fetching live data…"
    : live
      ? "live · /api/v1/today"
      : apiReachable
        ? "no curated event today · showing demo"
        : "offline · using bundled seed";
  const colorClass = live ? "text-accent" : apiReachable ? "text-ink-mute" : "text-warn";
  return (
    <div
      className={cn(
        "flex items-center justify-end gap-2 border-b border-rule-soft px-[clamp(20px,4vw,56px)] py-1.5 font-mono text-[11px] uppercase tracking-[1.4px]",
        colorClass,
      )}
    >
      <span
        className={cn(
          "h-1.5 w-1.5 rounded-full border border-current",
          live ? "bg-current" : "bg-transparent",
        )}
      />
      {label}
    </div>
  );
}

export const Route = createFileRoute("/")({
  component: TodayPage,
  validateSearch: (search: Record<string, unknown>): TodaySearch => ({
    event: typeof search.event === "string" ? search.event : undefined,
    lesson: typeof search.lesson === "string" ? search.lesson : undefined,
  }),
});
