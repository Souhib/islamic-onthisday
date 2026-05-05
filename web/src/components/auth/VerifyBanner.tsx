// Soft "please verify your email" banner shown on /saves while the
// account is still in the unverified state. The user can use the app
// already — this is a CTA, not a gate. The "Resend the email" action
// is best-effort: it always returns 204 server-side, so we just toggle
// a "on its way" message and re-enable after 30s.

import { useState } from "react";
import { useTranslation } from "react-i18next";
import { unwrap } from "@/api/errors";
import { resendVerificationEmailApiV1AuthEmailResendPost } from "@/api/generated/sdk.gen";
import { Eyebrow } from "@/components/design";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

interface Props {
  email: string;
}

type ResendState = "idle" | "sending" | "sent" | "failed";

export function VerifyBanner({ email }: Props) {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();
  const [state, setState] = useState<ResendState>("idle");

  async function handleResend() {
    setState("sending");
    try {
      const result = await resendVerificationEmailApiV1AuthEmailResendPost({ body: { email } });
      if (result.error !== undefined) unwrap(result);
      setState("sent");
    } catch {
      setState("failed");
    }
  }

  return (
    <aside
      role="status"
      className="mb-6 flex flex-col gap-2 border-l-2 border-accent bg-paper-hi/40 ps-4 pe-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:gap-5"
    >
      <div className="flex flex-col gap-1">
        <Eyebrow color="accent">{t("auth.verify_banner_title")}</Eyebrow>
        <p
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "text-[14px] leading-[1.5] text-ink-soft",
            isRTL ? "font-arabic" : "font-serif",
          )}
        >
          {t("auth.verify_banner_body", { email })}
        </p>
      </div>
      <div className="flex items-center gap-3">
        {state === "sent" && (
          <span className="font-mono text-[10.5px] uppercase tracking-[1.6px] text-accent">
            {t("auth.verify_banner_resent")}
          </span>
        )}
        {state === "failed" && (
          <span className="font-mono text-[10.5px] uppercase tracking-[1.6px] text-warn">
            {t("auth.verify_banner_resend_failed")}
          </span>
        )}
        <button
          type="button"
          onClick={handleResend}
          disabled={state === "sending" || state === "sent"}
          className="cursor-pointer border border-rule bg-transparent px-3 py-1.5 font-mono text-[10.5px] uppercase tracking-[1.6px] text-ink-soft transition-colors hover:border-ink hover:text-ink disabled:opacity-50"
        >
          {state === "sending" ? t("auth.submitting") : t("auth.verify_banner_resend")}
        </button>
      </div>
    </aside>
  );
}
