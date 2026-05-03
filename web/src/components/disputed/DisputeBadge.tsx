// Small inline marker that signals a disputed event. Lives wherever the
// event surfaces (Browse cards, Today headline, Event detail, the rotation
// rail) so a reader can never click into a disputed event without prior
// warning. Adapts the label to the kind of dispute (date / detail /
// interpretation) so the user knows what the dispute is about.

import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";

export type DisputeAbout = "date" | "detail" | "interpretation" | null | undefined;

interface Props {
  disputeAbout: DisputeAbout;
  size?: "xs" | "sm";
  onClick?: () => void;
  /** Override the auto-derived label (rare — the i18n version usually wins). */
  label?: string;
  className?: string;
}

const LABEL_KEYS: Record<"date" | "detail" | "interpretation", string> = {
  date: "date_varies",
  detail: "detail_contested",
  interpretation: "scholarly_interpretations",
};

export function DisputeBadge({ disputeAbout, size = "xs", onClick, label, className }: Props) {
  const { t } = useTranslation();
  const resolvedLabel =
    label ??
    (disputeAbout && LABEL_KEYS[disputeAbout] ? t(LABEL_KEYS[disputeAbout]) : t("scholarly_views"));
  const isInteractive = Boolean(onClick);
  const sizeClass = size === "sm" ? "text-[12px] px-2.5 py-[5px]" : "text-[11px] px-[7px] py-[3px]";
  const sharedClass = cn(
    "inline-flex items-center gap-1.5 whitespace-nowrap font-mono uppercase tracking-[1.2px] text-warn border border-warn",
    sizeClass,
    className,
  );

  if (isInteractive) {
    return (
      <button
        type="button"
        onClick={onClick}
        aria-label={`Open dispute drawer (${resolvedLabel})`}
        className={cn(sharedClass, "iotd-pick !block !w-auto cursor-pointer")}
      >
        <span className="block h-1.5 w-1.5 shrink-0 rounded-full bg-warn" />
        {resolvedLabel}
        <span className="ml-0.5">→</span>
      </button>
    );
  }

  return (
    <span className={sharedClass} aria-label={resolvedLabel}>
      <span className="block h-1.5 w-1.5 shrink-0 rounded-full bg-warn" />
      {resolvedLabel}
    </span>
  );
}
