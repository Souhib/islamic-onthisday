import { Outlet, createRootRoute, useLocation } from "@tanstack/react-router";
import { useEffect } from "react";
import { ErrorBoundary } from "@/components/ui/ErrorBoundary";
import { NotFound } from "@/components/ui/NotFound";
import { trackPageView } from "@/lib/analytics";
import { LanguageProvider } from "@/providers/LanguageProvider";
import { QueryProvider } from "@/providers/QueryProvider";
import { ThemeProvider } from "@/providers/ThemeProvider";

function RootLayout() {
  const location = useLocation();

  // Umami pageview on every navigation (TanStack Router does soft
  // transitions, so the script never sees a real `popstate`). The hook
  // also covers the initial landing.
  useEffect(() => {
    trackPageView(location.pathname, document.title);
  }, [location.pathname]);

  return (
    <ErrorBoundary>
      <QueryProvider>
        <ThemeProvider>
          <LanguageProvider>
            <Outlet />
          </LanguageProvider>
        </ThemeProvider>
      </QueryProvider>
    </ErrorBoundary>
  );
}

export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => <NotFound />,
});
