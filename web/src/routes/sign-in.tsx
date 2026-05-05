import { Link, createFileRoute, redirect, useNavigate } from "@tanstack/react-router";
import { type FormEvent, useState } from "react";
import { useTranslation } from "react-i18next";
import { useAuth } from "@/auth/AuthProvider";
import { PageShell } from "@/components/reader/PageShell";

function translateAuthError(rawMessage: string, t: (k: string) => string): string {
  const key = rawMessage.toLowerCase();
  if (key.includes("invalidcredentials") || key.includes("401")) return t("auth.errors.invalid_credentials");
  return t("auth.errors.generic");
}

function SignInPage() {
  const { t } = useTranslation();
  const { login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
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
      setError(translateAuthError(err instanceof Error ? err.message : String(err), t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <PageShell title={t("auth.sign_in")} subtitle={t("auth.sign_in_subtitle")}>
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
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="border border-rule bg-paper px-3 py-2 font-serif text-[16px] text-ink focus:border-accent focus:outline-none"
          />
        </label>

        {error && <p className="font-mono text-[12px] text-accent">{error}</p>}

        <button
          type="submit"
          disabled={submitting}
          className="mt-2 cursor-pointer border border-ink bg-ink px-4 py-2.5 font-mono text-[11.5px] uppercase tracking-[1.8px] text-paper disabled:opacity-50"
        >
          {submitting ? t("auth.submitting") : t("auth.submit_sign_in")}
        </button>

        <p className="text-center font-mono text-[11px] text-ink-soft">
          {t("auth.no_account")}{" "}
          <Link to="/sign-up" className="iotd-link underline-offset-2 hover:underline">
            {t("auth.sign_up")}
          </Link>
        </p>
      </form>
    </PageShell>
  );
}

export const Route = createFileRoute("/sign-in")({
  beforeLoad: ({ context: _context }) => {
    // Authenticated users skip the login page. We can't read auth from
    // the loader (it's not in context), so the component itself
    // double-checks below with a redirect on first paint.
  },
  component: SignInComponent,
});

function SignInComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  const navigate = useNavigate();
  if (isInitialised && isAuthenticated) {
    throw redirect({ to: "/saves" });
  }
  // Unused, but keeps lint happy if the redirect path changes.
  void navigate;
  return <SignInPage />;
}
