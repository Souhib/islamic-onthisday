import { Link, createFileRoute, useSearch } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { unwrap } from "@/api/errors";
import { confirmEmailChangeApiV1AuthMeEmailConfirmPost } from "@/api/generated/sdk.gen";
import { useAuth } from "@/auth/AuthProvider";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Loading } from "@/components/ui/Loading";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

interface ConfirmSearch {
  token?: string;
}

type ConfirmState = "idle" | "running" | "done" | "failed";

function ConfirmEmailChangePage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();
  const { logout, refreshUser } = useAuth();
  const search = useSearch({ from: "/confirm-email-change" });
  const token = (search as ConfirmSearch).token ?? "";

  const [state, setState] = useState<ConfirmState>(token ? "running" : "failed");

  useEffect(() => {
    if (!token) return;
    let cancelled = false;
    void (async () => {
      try {
        const result = await confirmEmailChangeApiV1AuthMeEmailConfirmPost({ body: { token } });
        unwrap(result);
        if (cancelled) return;
        // The user's email just changed under their own session — log
        // them out so they sign in again with the new address (this is
        // simpler than rotating the access token here, and clearly
        // signals the change to anyone with shared device access).
        logout();
        await refreshUser();
        setState("done");
      } catch {
        if (!cancelled) setState("failed");
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [token, logout, refreshUser]);

  return (
    <PageShell title={t("auth.account_email_change_done_title")}>
      <div className="mx-auto flex max-w-[440px] flex-col items-center gap-4 pt-2 pb-12 text-center">
        <EightPointStar
          size={28}
          strokeWidth={0.6}
          className={cn(state === "failed" ? "text-warn" : "text-accent")}
        />

        {state === "running" && <Loading />}

        {state === "done" && (
          <>
            <Eyebrow color="accent" className="mt-3">
              · {t("auth.account_email_change_done_title")} ·
            </Eyebrow>
            <h1
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "mt-3 text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
                isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
              )}
            >
              {t("auth.account_email_change_done_title")}
            </h1>
            <p
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "max-w-[380px] text-[15.5px] leading-[1.55] text-ink-soft text-pretty",
                isRTL ? "font-arabic" : "font-serif italic",
              )}
            >
              {t("auth.account_email_change_done_body")}
            </p>
            <FriezeRule rosetteOnly marginTop={20} marginBottom={4} />
            <Link
              to="/sign-in"
              className="cursor-pointer border border-ink bg-ink px-4 py-3 font-mono text-[11.5px] uppercase tracking-[2px] text-paper hover:opacity-90"
            >
              {t("auth.submit_sign_in")}
            </Link>
          </>
        )}

        {state === "failed" && (
          <>
            <h1
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "mt-3 text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-warn text-balance",
                isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
              )}
            >
              {t("auth.account_email_change_failed_title")}
            </h1>
            <p
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "max-w-[380px] text-[15.5px] leading-[1.55] text-ink-soft text-pretty",
                isRTL ? "font-arabic" : "font-serif italic",
              )}
            >
              {t("auth.account_email_change_failed_body")}
            </p>
            <Link
              to="/account"
              className="font-mono text-[11.5px] uppercase tracking-[1.4px] text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
            >
              {t("auth.account_back_to_settings")}
            </Link>
          </>
        )}
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/confirm-email-change")({
  validateSearch: (search: Record<string, unknown>): ConfirmSearch => ({
    token: typeof search.token === "string" ? search.token : undefined,
  }),
  component: ConfirmEmailChangePage,
});
