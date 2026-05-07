// Hidden test route — visit ``/_debug/crash`` to throw a render-time
// error and verify the Sentry / GlitchTip pipeline. Hidden because the
// route is namespace-prefixed (``_debug``) — search engines have no
// reason to crawl it, and there's no link to it from the app.
//
// Use ``/_debug/crash?type=async`` to trigger an unhandled promise
// rejection instead, which exercises the global ``unhandledrejection``
// handler in ``lib/sentry.ts``.

import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";

function CrashRoute() {
  const search = new URLSearchParams(window.location.search);
  const type = search.get("type") ?? "render";

  useEffect(() => {
    if (type === "async") {
      // Unhandled promise rejection — caught by ``window.onunhandledrejection``.
      void Promise.reject(new Error("[iotd] async crash test"));
    } else if (type === "global") {
      // Global error — caught by ``window.onerror``.
      setTimeout(() => {
        throw new Error("[iotd] global timeout crash test");
      }, 0);
    }
  }, [type]);

  if (type === "render") {
    throw new Error("[iotd] render crash test");
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-paper px-6 text-ink">
      <div className="max-w-[480px] text-center font-serif">
        <p className="mb-2 font-mono text-[11px] uppercase tracking-[2px] text-warn">
          · debug · {type} ·
        </p>
        <p className="text-[18px]">
          A {type === "async" ? "promise rejection" : "global error"} has been thrown.
          Open GlitchTip → iotd-web to confirm the event was captured.
        </p>
      </div>
    </div>
  );
}

export const Route = createFileRoute("/dev-crash")({
  component: CrashRoute,
});
