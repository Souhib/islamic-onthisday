// GlitchTip / Sentry-compatible error tracking. Self-hosted GlitchTip
// instance accepts the standard Sentry DSN format, so the official
// ``@sentry/react`` SDK works as-is — point ``VITE_SENTRY_DSN`` at the
// GlitchTip project's DSN and the SDK ships events there.
//
// Dev runs leave the DSN empty: no init, no network, zero footprint.

import * as Sentry from "@sentry/react";

const DSN = import.meta.env.VITE_SENTRY_DSN;

/**
 * Boot the SDK. Must run before ``createRoot`` so the SDK's React
 * integration can wrap the render tree. No-op when the DSN is empty.
 */
export function bootSentry(): void {
  if (!DSN) return;

  Sentry.init({
    dsn: DSN,
    environment: import.meta.env.MODE,
    release: import.meta.env.VITE_APP_VERSION,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration({
        maskAllText: false,
        blockAllMedia: false,
      }),
    ],
    // Sample rates tuned for a self-hosted GlitchTip with bounded
    // storage. 10% trace coverage in prod is enough to spot
    // regressions without blowing the server quota.
    tracesSampleRate: import.meta.env.PROD ? 0.1 : 1.0,
    replaysSessionSampleRate: import.meta.env.PROD ? 0.1 : 0,
    replaysOnErrorSampleRate: 1.0,
    beforeSend(event) {
      // Strip auth headers and any cookie that slipped into a request
      // breadcrumb — never trust the SDK's defaults to filter for us.
      if (event.request?.headers) {
        const headers = { ...event.request.headers };
        for (const key of Object.keys(headers)) {
          if (/^(authorization|cookie|set-cookie|x-api-key)$/i.test(key)) {
            headers[key] = "[redacted]";
          }
        }
        event.request.headers = headers;
      }
      return event;
    },
  });

  // Non-React paths: a plain ``throw`` from a setTimeout / addEventListener
  // / Promise without ``.catch`` skips the React error boundary entirely.
  // Wire global listeners so those still reach GlitchTip.
  window.addEventListener("error", (e) => {
    if (e.error instanceof Error) Sentry.captureException(e.error);
  });
  window.addEventListener("unhandledrejection", (e) => {
    Sentry.captureException(e.reason);
  });
}

export { Sentry };
