import { Link, createFileRoute, useNavigate } from "@tanstack/react-router";
import { type FormEvent, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { ApiError } from "@/api/errors";
import { useAuth } from "@/auth/AuthProvider";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

function pickSignupErrorMessage(err: unknown, t: (k: string) => string): string {
  if (err instanceof ApiError) {
    if (err.errorCode === "EmailAlreadyRegisteredError") return t("auth.errors.email_taken");
    if (err.status === 422) return t("auth.errors.weak_password");
    if (err.status === 429) return t("auth.errors.generic");
  }
  return t("auth.errors.generic");
}

const inputClass =
  "w-full border border-rule bg-paper px-3.5 py-2.5 font-serif text-[16px] text-ink placeholder:text-ink-faint focus:border-accent focus:outline-none focus:ring-0";

const labelTextClass = "font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft";

const MIN_PASSWORD_CHARS = 8;

function SignUpPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();
  const { signup } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [displayName, setDisplayName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    if (password.length < MIN_PASSWORD_CHARS) {
      setError(t("auth.errors.weak_password"));
      return;
    }
    setSubmitting(true);
    try {
      await signup(email.trim(), password, displayName.trim() || undefined);
      void navigate({ to: "/saves" });
    } catch (err) {
      setError(pickSignupErrorMessage(err, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageShell title={t("auth.sign_up")}>
      <div className="mx-auto flex max-w-[440px] flex-col items-center gap-1 pt-2 pb-12">
        <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
        <Eyebrow color="accent" className="mt-3">
          · {t("auth.sign_up")} ·
        </Eyebrow>
        <h1
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 text-center text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
            isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
          )}
        >
          {t("auth.sign_up")}
        </h1>
        <p
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 max-w-[360px] text-center text-[15.5px] leading-[1.5] text-ink-soft text-pretty",
            isRTL ? "font-arabic" : "font-serif italic",
          )}
        >
          {t("auth.sign_up_subtitle")}
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

          <label className="flex flex-col gap-1.5">
            <span className="flex items-baseline justify-between gap-3">
              <span className={labelTextClass}>{t("auth.password")}</span>
              <span className="font-mono text-[10px] tracking-[1px] text-ink-faint">
                {t("auth.password_min_hint", { count: MIN_PASSWORD_CHARS })}
              </span>
            </span>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                minLength={MIN_PASSWORD_CHARS}
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className={cn(inputClass, isRTL ? "pl-12" : "pr-12")}
              />
              <button
                type="button"
                onClick={() => setShowPassword((v) => !v)}
                aria-label={showPassword ? t("auth.hide_password") : t("auth.show_password")}
                className={cn(
                  "absolute inset-y-0 flex items-center px-3 font-mono text-[10.5px] uppercase tracking-[1.4px] text-ink-mute hover:text-ink",
                  isRTL ? "left-0" : "right-0",
                )}
              >
                {showPassword ? t("auth.hide") : t("auth.show")}
              </button>
            </div>
          </label>

          <label className="flex flex-col gap-1.5">
            <span className={labelTextClass}>{t("auth.display_name")}</span>
            <input
              type="text"
              autoComplete="nickname"
              maxLength={64}
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
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
            {submitting ? t("auth.submitting") : t("auth.submit_sign_up")}
          </button>
        </form>

        <p className="mt-7 text-center font-mono text-[11.5px] uppercase tracking-[1.4px] text-ink-soft">
          {t("auth.have_account")}{" "}
          <Link to="/sign-in" className="iotd-link text-ink underline-offset-4 hover:underline">
            {t("auth.sign_in")}
          </Link>
        </p>
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/sign-up")({
  component: SignUpComponent,
});

function SignUpComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  const navigate = useNavigate();
  // See sign-in.tsx — effect-based redirect avoids throwing ``redirect()`` mid
  // state transition (auth flipping after a successful signup).
  useEffect(() => {
    if (isInitialised && isAuthenticated) {
      void navigate({ to: "/saves", replace: true });
    }
  }, [isInitialised, isAuthenticated, navigate]);

  if (isInitialised && isAuthenticated) return null;
  return <SignUpPage />;
}
