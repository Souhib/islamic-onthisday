import { Link, createFileRoute, redirect, useNavigate } from "@tanstack/react-router";
import { type FormEvent, useState } from "react";
import { useTranslation } from "react-i18next";
import { useAuth } from "@/auth/AuthProvider";
import { PageShell } from "@/components/reader/PageShell";

function translateSignupError(rawMessage: string, t: (k: string) => string): string {
  const key = rawMessage.toLowerCase();
  if (key.includes("emailalreadyregistered") || key.includes("409")) return t("auth.errors.email_taken");
  if (key.includes("422")) return t("auth.errors.weak_password");
  return t("auth.errors.generic");
}

function SignUpPage() {
  const { t } = useTranslation();
  const { signup } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    if (password.length < 8) {
      setError(t("auth.errors.weak_password"));
      return;
    }
    setSubmitting(true);
    try {
      await signup(email.trim(), password, displayName.trim() || undefined);
      void navigate({ to: "/saves" });
    } catch (err) {
      setError(translateSignupError(err instanceof Error ? err.message : String(err), t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageShell title={t("auth.sign_up")} subtitle={t("auth.sign_up_subtitle")}>
      <form onSubmit={handleSubmit} className="mx-auto flex max-w-[420px] flex-col gap-4 pt-4">
        <label className="flex flex-col gap-1.5">
          <span className="font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft">{t("auth.email")}</span>
          <input
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="border border-rule bg-paper px-3 py-2 font-serif text-[16px] text-ink focus:border-accent focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1.5">
          <span className="font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft">{t("auth.password")}</span>
          <input
            type="password"
            required
            minLength={8}
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="border border-rule bg-paper px-3 py-2 font-serif text-[16px] text-ink focus:border-accent focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1.5">
          <span className="font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft">{t("auth.display_name")}</span>
          <input
            type="text"
            autoComplete="nickname"
            maxLength={64}
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="border border-rule bg-paper px-3 py-2 font-serif text-[16px] text-ink focus:border-accent focus:outline-none"
          />
        </label>

        {error && <p className="font-mono text-[12px] text-accent">{error}</p>}

        <button
          type="submit"
          disabled={submitting}
          className="mt-2 cursor-pointer border border-ink bg-ink px-4 py-2.5 font-mono text-[11.5px] uppercase tracking-[1.8px] text-paper disabled:opacity-50"
        >
          {submitting ? t("auth.submitting") : t("auth.submit_sign_up")}
        </button>

        <p className="text-center font-mono text-[11px] text-ink-soft">
          {t("auth.have_account")}{" "}
          <Link to="/sign-in" className="iotd-link underline-offset-2 hover:underline">
            {t("auth.sign_in")}
          </Link>
        </p>
      </form>
    </PageShell>
  );
}

export const Route = createFileRoute("/sign-up")({
  component: SignUpComponent,
});

function SignUpComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  if (isInitialised && isAuthenticated) {
    throw redirect({ to: "/saves" });
  }
  return <SignUpPage />;
}
