// Mono "404" eyebrow + italic-serif explanation, with a "back to today"
// affordance. Used by detail-route error states and the router's global
// not-found page.

import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

interface Props {
  /** Optional explanation, usually the slug that wasn't found. */
  message?: string;
}

export function NotFound({ message }: Props) {
  const { t } = useTranslation();
  return (
    <div className="py-[60px] text-center">
      <div className="mb-3 font-mono text-[12px] uppercase tracking-[2px] text-warn">· 404 ·</div>
      {message && <div className="font-serif text-[20px] italic text-ink">{message}</div>}
      <Link to="/" className="mt-6 inline-block text-accent underline">
        {t("back_to_today")}
      </Link>
    </div>
  );
}
