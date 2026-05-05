import { Link, createFileRoute, useSearch } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { ApiError, unwrap } from "@/api/errors";
import { verifyEmailApiV1AuthEmailVerifyPost } from "@/api/generated/sdk.gen";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { Loading } from "@/components/ui/Loading";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

interface VerifySearch {
  token?: string;
}

type VerifyState = "idle" | "running" | "done" | "failed";

function VerifyEmailPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();
  const search = useSearch({ from: "/verify-email" });
  const token = (search as VerifySearch).token ?? "";

  const [state, setState] = useState<VerifyState>(token ? "running" : "failed");

  useEffect(() => {
    if (!token) return;
    let cancelled = false;
    void (async () => {
      try {
        const result = await verifyEmailApiV1AuthEmailVerifyPost({ body: { token } });
        if (result.error !== undefined) unwrap(result);
        if (!cancelled) setState("done");
      } catch (err) {
        if (cancelled) return;
        if (err instanceof ApiError && err.errorCode === "InvalidEmailVerificationTokenError") {
          setState("failed");
        } else {
          setState("failed");
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [token]);

  return (
    <PageShell title={t("auth.verify_email_title")}>
      <div className="mx-auto flex max-w-[440px] flex-col items-center gap-4 pt-2 pb-12 text-center">
        <EightPointStar
          size={28}
          strokeWidth={0.6}
          className={cn(state === "failed" ? "text-warn" : "text-accent")}
        />
        <Eyebrow color="accent" className="mt-3">
          · {t("auth.verify_email_title")} ·
        </Eyebrow>

        {state === "running" && <Loading />}

        {state === "done" && (
          <>
            <h1
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "mt-3 text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
                isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
              )}
            >
              {t("auth.verify_email_done_title")}
            </h1>
            <p
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "max-w-[380px] text-[15.5px] leading-[1.55] text-ink-soft text-pretty",
                isRTL ? "font-arabic" : "font-serif italic",
              )}
            >
              {t("auth.verify_email_done_body")}
            </p>
            <FriezeRule rosetteOnly marginTop={20} marginBottom={4} />
            <Link
              to="/saves"
              className="cursor-pointer border border-ink bg-ink px-4 py-3 font-mono text-[11.5px] uppercase tracking-[2px] text-paper hover:opacity-90"
            >
              {t("auth.saves")}
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
              {t("auth.verify_email_failed_title")}
            </h1>
            <p
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "max-w-[380px] text-[15.5px] leading-[1.55] text-ink-soft text-pretty",
                isRTL ? "font-arabic" : "font-serif italic",
              )}
            >
              {token ? t("auth.verify_email_failed_body") : t("auth.missing_token")}
            </p>
            <Link
              to="/saves"
              className="font-mono text-[11.5px] uppercase tracking-[1.4px] text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
            >
              {t("auth.saves")}
            </Link>
          </>
        )}
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/verify-email")({
  validateSearch: (search: Record<string, unknown>): VerifySearch => ({
    token: typeof search.token === "string" ? search.token : undefined,
  }),
  component: VerifyEmailPage,
});
