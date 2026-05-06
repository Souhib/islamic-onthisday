import { Link, createFileRoute, useNavigate } from "@tanstack/react-router";
import { type FormEvent, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { ApiError, unwrap } from "@/api/errors";
import {
  changeDisplayNameApiV1AuthMePatch,
  changePasswordApiV1AuthMePasswordPost,
  requestEmailChangeApiV1AuthMeEmailPost,
} from "@/api/generated/sdk.gen";
import { useAuth } from "@/auth/AuthProvider";
import { EightPointStar, Eyebrow, FriezeRule } from "@/components/design";
import { PageShell } from "@/components/reader/PageShell";
import { cn } from "@/lib/utils";
import { useLanguage } from "@/providers/LanguageProvider";

const inputClass =
  "w-full border border-rule bg-paper px-3.5 py-2.5 font-serif text-[16px] text-ink placeholder:text-ink-faint focus:border-accent focus:outline-none focus:ring-0";
const labelTextClass = "font-mono text-[11px] uppercase tracking-[1.6px] text-ink-soft";
const submitClass =
  "mt-1 cursor-pointer border border-ink bg-ink px-4 py-2.5 font-mono text-[11.5px] uppercase tracking-[2px] text-paper transition-opacity hover:opacity-90 disabled:cursor-wait disabled:opacity-50";
const sectionClass = "border-t border-rule pt-7 pb-2";

function pickError(err: unknown, t: (k: string) => string): string {
  if (err instanceof ApiError) {
    if (err.errorCode === "WrongCurrentPasswordError") return t("auth.errors_wrong_current_password");
    if (err.errorCode === "EmailAlreadyRegisteredError") return t("auth.errors.email_taken");
    if (err.status === 422) return t("auth.errors.weak_password");
  }
  return t("auth.errors.generic");
}

function DisplayNameSection() {
  const { t } = useTranslation();
  const { user, refreshUser } = useAuth();
  const [value, setValue] = useState(user?.displayName ?? "");
  const [submitting, setSubmitting] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (user) setValue(user.displayName ?? "");
  }, [user]);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setSaved(false);
    setSubmitting(true);
    try {
      const result = await changeDisplayNameApiV1AuthMePatch({
        body: { displayName: value.trim() },
      });
      const updated = unwrap(result);
      // Don't wait on the round-trip — the response IS the fresh profile.
      void refreshUser();
      setValue(updated.displayName ?? "");
      setSaved(true);
    } catch (err) {
      setError(pickError(err, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className={cn(sectionClass, "flex flex-col gap-3")}>
      <Eyebrow color="accent">· {t("auth.account_section_display_name")} ·</Eyebrow>
      <label className="flex flex-col gap-1.5">
        <span className={labelTextClass}>{t("auth.display_name")}</span>
        <input
          type="text"
          required
          minLength={1}
          maxLength={64}
          autoComplete="nickname"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className={inputClass}
        />
      </label>
      {error && <p className="font-mono text-[12px] text-warn">{error}</p>}
      {saved && <p className="font-mono text-[11px] uppercase tracking-[1.6px] text-accent">{t("auth.account_saved")}</p>}
      <button type="submit" disabled={submitting} className={submitClass}>
        {submitting ? t("auth.submitting") : t("auth.account_save")}
      </button>
    </form>
  );
}

function PasswordSection() {
  const { t } = useTranslation();
  const [current, setCurrent] = useState("");
  const [next, setNext] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setDone(false);
    setSubmitting(true);
    try {
      const result = await changePasswordApiV1AuthMePasswordPost({
        body: { currentPassword: current, newPassword: next },
      });
      if (result.error !== undefined) unwrap(result);
      setCurrent("");
      setNext("");
      setDone(true);
    } catch (err) {
      setError(pickError(err, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className={cn(sectionClass, "flex flex-col gap-3")}>
      <Eyebrow color="accent">· {t("auth.account_section_password")} ·</Eyebrow>
      <label className="flex flex-col gap-1.5">
        <span className={labelTextClass}>{t("auth.account_current_password")}</span>
        <input
          type="password"
          required
          autoComplete="current-password"
          value={current}
          onChange={(e) => setCurrent(e.target.value)}
          className={inputClass}
        />
      </label>
      <label className="flex flex-col gap-1.5">
        <span className="flex items-baseline justify-between gap-3">
          <span className={labelTextClass}>{t("auth.account_new_password")}</span>
          <span className="font-mono text-[10px] tracking-[1px] text-ink-faint">
            {t("auth.password_min_hint", { count: 8 })}
          </span>
        </span>
        <input
          type="password"
          required
          minLength={8}
          autoComplete="new-password"
          value={next}
          onChange={(e) => setNext(e.target.value)}
          className={inputClass}
        />
      </label>
      {error && <p className="font-mono text-[12px] text-warn">{error}</p>}
      {done && (
        <p className="font-serif text-[14px] italic leading-[1.45] text-accent">
          {t("auth.account_password_changed")}
        </p>
      )}
      <button type="submit" disabled={submitting} className={submitClass}>
        {submitting ? t("auth.submitting") : t("auth.account_save")}
      </button>
    </form>
  );
}

function EmailSection() {
  const { t } = useTranslation();
  const { user } = useAuth();
  const [password, setPassword] = useState("");
  const [newEmail, setNewEmail] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [pendingEmail, setPendingEmail] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const result = await requestEmailChangeApiV1AuthMeEmailPost({
        body: { currentPassword: password, newEmail: newEmail.trim() },
      });
      if (result.error !== undefined) unwrap(result);
      setPendingEmail(newEmail.trim());
      setPassword("");
      setNewEmail("");
    } catch (err) {
      setError(pickError(err, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className={cn(sectionClass, "flex flex-col gap-3")}>
      <Eyebrow color="accent">· {t("auth.account_section_email")} ·</Eyebrow>
      <p className="font-mono text-[11px] uppercase tracking-[1.4px] text-ink-mute">
        {user?.email}
      </p>
      <label className="flex flex-col gap-1.5">
        <span className={labelTextClass}>{t("auth.account_new_email")}</span>
        <input
          type="email"
          required
          inputMode="email"
          autoComplete="email"
          value={newEmail}
          onChange={(e) => setNewEmail(e.target.value)}
          className={inputClass}
        />
      </label>
      <label className="flex flex-col gap-1.5">
        <span className={labelTextClass}>{t("auth.account_current_password")}</span>
        <input
          type="password"
          required
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className={inputClass}
        />
      </label>
      {error && <p className="font-mono text-[12px] text-warn">{error}</p>}
      {pendingEmail && (
        <p className="font-serif text-[14px] italic leading-[1.45] text-accent">
          {t("auth.account_email_pending", { email: pendingEmail })}
        </p>
      )}
      <button type="submit" disabled={submitting} className={submitClass}>
        {submitting ? t("auth.submitting") : t("auth.account_send_link")}
      </button>
    </form>
  );
}

function AccountPage() {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();

  return (
    <PageShell title={t("auth.account_title")}>
      <div className="mx-auto flex max-w-[480px] flex-col items-center gap-1 pt-2 pb-12">
        <EightPointStar size={28} className="text-accent" strokeWidth={0.6} />
        <Eyebrow color="accent" className="mt-3">
          · {t("auth.account_title")} ·
        </Eyebrow>
        <h1
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 text-center text-[clamp(28px,3.4vw,40px)] font-medium leading-[1.05] text-ink text-balance",
            isRTL ? "font-arabic" : "font-serif tracking-[-1.2px]",
          )}
        >
          {t("auth.account_title")}
        </h1>
        <p
          dir={isRTL ? "rtl" : "ltr"}
          className={cn(
            "mt-3 max-w-[400px] text-center text-[15px] leading-[1.5] text-ink-soft text-pretty",
            isRTL ? "font-arabic" : "font-serif italic",
          )}
        >
          {t("auth.account_subtitle")}
        </p>

        <FriezeRule rosetteOnly marginTop={28} marginBottom={4} />

        <div className="w-full">
          <DisplayNameSection />
          <EmailSection />
          <PasswordSection />
        </div>

        <p className="mt-7 text-center font-mono text-[11.5px] uppercase tracking-[1.4px] text-ink-soft">
          <Link
            to="/saves"
            className="font-medium text-accent underline decoration-accent/40 underline-offset-[5px] transition-colors hover:decoration-accent"
          >
            {t("auth.saves")}
          </Link>
        </p>
      </div>
    </PageShell>
  );
}

export const Route = createFileRoute("/account")({
  component: AccountComponent,
});

function AccountComponent() {
  const { isAuthenticated, isInitialised } = useAuth();
  const navigate = useNavigate();
  useEffect(() => {
    if (isInitialised && !isAuthenticated) {
      void navigate({ to: "/sign-in", replace: true });
    }
  }, [isInitialised, isAuthenticated, navigate]);

  if (!isInitialised || !isAuthenticated) return null;
  return <AccountPage />;
}
