// Umami analytics — privacy-friendly, self-hosted, gated on env vars.
//
// Init pattern is lifted from LaTabdhir (`LaTabdhir/front/src/lib/umami.ts`):
// when `VITE_UMAMI_URL` + `VITE_UMAMI_WEBSITE_ID` are both set, we inject
// the Umami `<script>` at boot. Otherwise the SDK never loads — every
// helper below becomes a silent no-op. Zero overhead in dev, zero
// privacy footprint when disabled.
//
// **Event policy.** The site is content-driven, not transactional, so we
// only track signals that answer real product questions:
//
// - page views (auto, on route change) — daily-return rhythm
// - {event,lesson,observance,person}_view — what people read
// - search — what people look for, with result count
// - language_change — trilingual reach signal
// - dispute_opened — engagement with the editorial dispute model
//
// We deliberately don't track theme toggles, filter clicks, pagination,
// or hover events — those are noise that bloat the dashboard without
// answering any decision.

const UMAMI_URL = import.meta.env.VITE_UMAMI_URL;
const UMAMI_WEBSITE_ID = import.meta.env.VITE_UMAMI_WEBSITE_ID;

interface UmamiPayload {
  hostname: string;
  language: string;
  referrer: string;
  screen: string;
  title: string;
  url: string;
  website: string;
}

// Umami's `track` is overloaded:
//   track()                                — record a page view at the current URL
//   track((props) => ({ ...props, url }))  — page view with a custom URL/title
//   track(name, data?)                     — custom named event
type UmamiTracker = {
  track: ((callback: (props: UmamiPayload) => object) => void) &
    ((eventName: string, data?: Record<string, unknown>) => void) &
    (() => void);
};

declare global {
  interface Window {
    umami?: UmamiTracker;
  }
}

/**
 * Inject the Umami script at boot. No-op when env vars aren't set.
 *
 * Call once from `main.tsx` before rendering. Subsequent calls are
 * idempotent — the function checks for an existing script tag.
 */
export function initAnalytics(): void {
  if (!UMAMI_URL || !UMAMI_WEBSITE_ID) return;
  if (document.getElementById("umami-script")) return;

  const script = document.createElement("script");
  script.id = "umami-script";
  script.async = true;
  script.defer = true;
  script.src = `${UMAMI_URL}/script.js`;
  script.setAttribute("data-website-id", UMAMI_WEBSITE_ID);
  // We track page views manually on route change (TanStack Router doesn't
  // trigger a real navigation), so disable Umami's auto-track.
  script.setAttribute("data-auto-track", "false");
  document.head.appendChild(script);
}

/**
 * Send a custom event. Silently no-ops when Umami isn't loaded —
 * either env vars aren't set, the script hasn't finished loading yet,
 * or a privacy extension is blocking it.
 */
function track(event: string, data?: Record<string, unknown>): void {
  window.umami?.track(event, data);
}

// ---------------------------------------------------------------------------
// Page views — call on every route change.
// ---------------------------------------------------------------------------

/**
 * Record a page view at ``path``. The Umami script may still be loading
 * when the first navigation happens; we retry briefly so the initial
 * landing isn't dropped.
 */
export function trackPageView(path: string, title?: string): void {
  if (!UMAMI_URL || !UMAMI_WEBSITE_ID) return;

  const send = () => {
    window.umami?.track((props) => ({
      ...props,
      url: path,
      title: title ?? document.title,
    }));
  };

  if (window.umami) {
    send();
    return;
  }

  // Poll for up to 5 seconds — Umami loads async and the first route
  // resolves before its `<script>` finishes parsing. Drop after that:
  // not worth keeping the interval alive longer for a page view.
  const interval = window.setInterval(() => {
    if (window.umami) {
      window.clearInterval(interval);
      send();
    }
  }, 200);
  window.setTimeout(() => window.clearInterval(interval), 5000);
}

// ---------------------------------------------------------------------------
// Domain-specific helpers. Exhaustively named so an IDE autocompletes
// the full menu of trackable signals.
// ---------------------------------------------------------------------------

/** User opened an event detail page. */
export function trackEventView(slug: string): void {
  track("event_view", { slug });
}

/** User opened a lesson detail page. */
export function trackLessonView(slug: string): void {
  track("lesson_view", { slug });
}

/** User opened an observance detail page. */
export function trackObservanceView(slug: string): void {
  track("observance_view", { slug });
}

/** User opened a person profile page. */
export function trackPersonView(slug: string): void {
  track("person_view", { slug });
}

/** Search query with the number of results returned (0 = no match). */
export function trackSearch(term: string, resultCount: number): void {
  // Trim and clip the term so we don't blow up Umami with novelty payloads
  // (a 4kb search box would otherwise dominate the events table).
  const trimmed = term.trim().slice(0, 80);
  if (!trimmed) return;
  track("search", { term: trimmed, results: resultCount });
}

/** User switched UI language. Signals real trilingual reach. */
export function trackLanguageChange(language: "en" | "fr" | "ar"): void {
  track("language_change", { language });
}

/** User opened the disputed-views drawer. Engagement with the editorial model. */
export function trackDisputeOpened(slug: string): void {
  track("dispute_opened", { slug });
}
