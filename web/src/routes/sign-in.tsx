import { Link, createFileRoute, useNavigate } from "@tanstack/react-router";
import { type FormEvent, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { ApiError } from "@/api/errors";
import { useAuth } from "@/auth/AuthProvider";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

function pickLoginErrorMessage(err: unknown, t: (k: string) => string): string {
  if (err instanceof ApiError) {
    if (err.errorCode === "InvalidCredentialsError") return t("auth.errors.invalid_credentials");
    if (err.errorCode === "RateLimitExceededError" || err.status === 429) {
      return t("auth.errors.generic");
    }
  }
  return t("auth.errors.generic");
}

const inputClass =
  "w-full border border-rule bg-paper px-3.5 py-2.5 font-serif text-[16px] text-ink placeholder:text-ink-faint focus:border-accent focus:outline-none focus:ring-0";

const labelTextClass = "font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft";

function SignInPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();
  const { login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await login(email.trim(), password);
      void navigate({ to: "/saves" });
    } catch (err) {
      setError(pickLoginErrorMessage(err, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageShell title={t("auth.sign_in")}>
      <div className="mx-auto flex max-w-[440px] flex-col items-center gap-1 pt-2 pb-12">
        <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
        <Eyebrow color="accent" className="mt-3">
          · {t("auth.sign_in")} ·
        </Eyebrow>
        <h1
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 text-center text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
            isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
          )}
        >
          {t("auth.sign_in")}
        </h1>
        <p
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 max-w-[360px] text-center text-[15.5px] leading-[1.5] text-ink-soft text-pretty",
            isRTL ? "font-arabic" : "font-serif italic",
          )}
        >
          {t("auth.sign_in_subtitle")}
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
            <span className={labelTextClass}>{t("auth.password")}</span>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                autoComplete="current-password"
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
            {submitting ? t("auth.submitting") : t("auth.submit_sign_in")}
          </button>
        </form>

        <Link
          to="/forgot-password"
          className="mt-5 font-mono text-[11px] uppercase tracking-[1.4px] text-ink-mute underline decoration-rule underline-offset-[5px] transition-colors hover:text-accent hover:decoration-accent"
        >
          {t("auth.forgot_password")}
        </Link>

        <p className="mt-7 text-center font-mono text-[11.5px] uppercase tracking-[1.4px] text-ink-soft">
          {t("auth.no_account")}{" "}
          <Link
            to="/sign-up"
            className="font-medium text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
          >
            {t("auth.sign_up")}
          </Link>
        </p>
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/sign-in")({
  component: SignInComponent,
});

function SignInComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  const navigate = useNavigate();
  // Anyone already signed in (after a fresh login or because they never signed
  // out) bounces straight to /saves. We use an effect rather than throwing
  // ``redirect()`` from render — TanStack Router treats render-time throws as
  // uncaught errors when they happen mid-state-transition, which is exactly
  // the case right after a successful login flips ``isAuthenticated``.
  useEffect(() => {
    if (isInitialised && isAuthenticated) {
      void navigate({ to: "/saves", replace: true });
    }
  }, [isInitialised, isAuthenticated, navigate]);

  if (isInitialised && isAuthenticated) return null;
  return <SignInPage />;
}
