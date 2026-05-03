import * as Sentry from "@sentry/react";
import { RouterProvider, createRouter } from "@tanstack/react-router";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { routeTree } from "./routeTree.gen";
import "./index.css";
import "@/api/client-setup";
import "@/i18n";
import { initAnalytics } from "@/lib/analytics";

// Sentry — gated on a DSN env var so dev runs cost nothing. Production
// builds bake a non-empty `VITE_SENTRY_DSN` and the SDK starts capturing.
if (import.meta.env.VITE_SENTRY_DSN) {
  Sentry.init({
    dsn: import.meta.env.VITE_SENTRY_DSN,
    environment: import.meta.env.MODE,
    release: import.meta.env.VITE_APP_VERSION,
    tracesSampleRate: 0.1,
  });
}

// Umami — gated on VITE_UMAMI_URL + VITE_UMAMI_WEBSITE_ID. Same shape:
// no env = no script, no network, zero footprint in dev.
initAnalytics();

const router = createRouter({
  routeTree,
  // Prefetch route bundles + queries on link hover/focus.
  defaultPreload: "intent",
  defaultPreloadStaleTime: 0,
  scrollRestoration: true,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

const root = document.getElementById("root");
if (!root) throw new Error("Missing #root");

createRoot(root).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>,
);
