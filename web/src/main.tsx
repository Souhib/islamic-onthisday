import { RouterProvider, createRouter } from "@tanstack/react-router";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { routeTree } from "./routeTree.gen";
import "./index.css";
import "@/api/client-setup";
import "@/i18n";
import { initAnalytics } from "@/lib/analytics";
import { bootSentry } from "@/lib/sentry";

// Boot GlitchTip / Sentry first — gated on ``VITE_SENTRY_DSN`` so dev
// runs cost nothing. The SDK installs ``window.error`` /
// ``unhandledrejection`` listeners as part of init, so anything
// thrown after this line lands in GlitchTip.
bootSentry();

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
