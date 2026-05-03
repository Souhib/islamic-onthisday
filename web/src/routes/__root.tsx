import { Outlet, createRootRoute } from "@tanstack/react-router";
import { ErrorBoundary } from "@/components/ui/ErrorBoundary";
import { NotFound } from "@/components/ui/NotFound";
import { LanguageProvider } from "@/providers/LanguageProvider";
import { QueryProvider } from "@/providers/QueryProvider";
import { ThemeProvider } from "@/providers/ThemeProvider";

export const Route = createRootRoute({
  component: () => (
    <ErrorBoundary>
      <QueryProvider>
        <ThemeProvider>
          <LanguageProvider>
            <Outlet />
          </LanguageProvider>
        </ThemeProvider>
      </QueryProvider>
    </ErrorBoundary>
  ),
  notFoundComponent: () => <NotFound />,
});
