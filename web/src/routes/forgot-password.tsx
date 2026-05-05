import { Link, createFileRoute } from "@tanstack/react-router";
import { type FormEvent, useState } from "react";
import { useTranslation } from "react-i18next";
import { unwrap } from "@/api/errors";
import { requestPasswordResetApiV1AuthPasswordResetRequestPost } from "@/api/generated/sdk.gen";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

const inputClass =
  "w-full border border-rule bg-paper px-3.5 py-2.5 font-serif text-[16px] text-ink placeholder:text-ink-faint focus:border-accent focus:outline-none focus:ring-0";
const labelTextClass = "font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft";

function ForgotPasswordPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();

  const [email, setEmail] = useState("");
  const [submitting, setSubmitting] = useState(false);
  // The backend always returns 204 to avoid leaking account existence; the
  // FE flips into a generic "if it exists, the email is on its way" pane
  // regardless of whether anything was actually sent.
  const [sent, setSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const result = await requestPasswordResetApiV1AuthPasswordResetRequestPost({
        body: { email: email.trim() },
      });
      // 204 No Content — unwrap won't have data either way; we just need
      // the call not to have errored.
      if (result.error !== undefined) unwrap(result);
      setSent(true);
    } catch {
      setError(t("auth.errors.generic"));
    } finally {
      setSubmitting(false);
    }
  }

  if (sent) {
    return (
      <PageShell title={t("auth.forgot_password_title")}>
        <div className="mx-auto flex max-w-[440px] flex-col items-center gap-4 pt-2 pb-12 text-center">
          <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
          <Eyebrow color="accent" className="mt-3">
            · {t("auth.forgot_password_sent_title")} ·
          </Eyebrow>
          <h1
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "mt-3 text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
              isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
            )}
          >
            {t("auth.forgot_password_sent_title")}
          </h1>
          <p
            dir={isRTL ? "rtl" : "ltr"}
            className={cn(
              "max-w-[380px] text-[15.5px] leading-[1.55] text-ink-soft text-pretty",
              isRTL ? "font-arabic" : "font-serif italic",
            )}
          >
            {t("auth.forgot_password_sent_body")}
          </p>
          <FriezeRule rosetteOnly marginTop={20} marginBottom={4} />
          <Link
            to="/sign-in"
            className="font-mono text-[11.5px] uppercase tracking-[1.4px] text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
          >
            {t("auth.back_to_sign_in")}
          </Link>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell title={t("auth.forgot_password_title")}>
      <div className="mx-auto flex max-w-[440px] flex-col items-center gap-1 pt-2 pb-12">
        <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
        <Eyebrow color="accent" className="mt-3">
          · {t("auth.forgot_password_title")} ·
        </Eyebrow>
        <h1
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 text-center text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
            isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
          )}
        >
          {t("auth.forgot_password_title")}
        </h1>
        <p
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 max-w-[380px] text-center text-[15.5px] leading-[1.5] text-ink-soft text-pretty",
            isRTL ? "font-arabic" : "font-serif italic",
          )}
        >
          {t("auth.forgot_password_subtitle")}
        </p>

        <FriezeRule rosetteOnly marginTop={28} marginBottom={24} />

        <form onSubmit={handleSubmit} className="flex w-full flex-col gap-4">
          <label className="flex flex-col gap-1.5">
            <span className={labelTextClass}>{t("auth.email")}</span>
            <input
              type="email"
              required
              autoFocus
              autoComplete="email"
              inputMode="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={inputClass}
            />
          </label>

          {error && (
            <p
              role="alert"
              dir={isRTL ? "rtl" : "ltr"}
              className={cn(
                "mt-1 border-l-2 border-warn ps-3 font-serif text-[14px] italic leading-[1.45] text-warn",
                isRTL && "border-l-0 border-r-2 ps-0 pe-3",
              )}
            >
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="mt-2 cursor-pointer border border-ink bg-ink px-4 py-3 font-mono text-[11.5px] uppercase tracking-[2px] text-paper transition-opacity hover:opacity-90 disabled:cursor-wait disabled:opacity-50"
          >
            {submitting ? t("auth.submitting") : t("auth.forgot_password_submit")}
          </button>
        </form>

        <p className="mt-7 text-center font-mono text-[11.5px] uppercase tracking-[1.4px] text-ink-soft">
          <Link
            to="/sign-in"
            className="font-medium text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
          >
            {t("auth.back_to_sign_in")}
          </Link>
        </p>
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/forgot-password")({
  component: ForgotPasswordPage,
});
