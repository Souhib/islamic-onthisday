// Single source of truth for the "Sign in" / "Saves" header affordance.
//
// Drops into Masthead, DetailHeader, and PageShell so every page in the
// app gets the same auth-aware control without having three near-
// identical conditionals to keep in sync.
//
// Returns null while the auth state is still hydrating from localStorage,
// so we don't flash "Sign in" for a tenth of a second to a returning
// signed-in visitor.

import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { useAuth } from "@/auth/AuthProvider";
import { cn } from "@/lib/utils";

interface Props {
  /** Mono uppercase label classes — passed in so each header can match its own row. */
  className?: string;
}

export function AccountLink({ className }: Props) {
  const { t } = useTranslation();
  const { isAuthenticated, isInitialised } = useAuth();

  if (!isInitialised) return null;

  if (isAuthenticated) {
    return (
      <Link to="/saves" className={cn("iotd-link", className)}>
        {t("auth.saves")}
      </Link>
    );
  }
  return (
    <Link to="/sign-in" className={cn("iotd-link", className)}>
      {t("auth.sign_in")}
    </Link>
  );
}
