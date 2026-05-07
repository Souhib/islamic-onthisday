// Editorial footnote-style annotation glued to a date string when the
// underlying event has `disputed: true`. Borrowed from print scholarship:
// dotted underline + dagger sigil signals "this datum has a scholarly note".
// Click opens the existing DisputedDrawer so the reader can read the
// alternative positions and the source citations.
//
// Why not a chip: the dispute is *about a specific datum* (the date), not
// a label hanging off the article. Anchoring the affordance directly to
// the disputed text keeps the design language editorial (matches the drop
// caps / frieze rules / mono colophons elsewhere) and satisfies the
// "color-not-only" rule — the dotted underline + sigil convey
// interactivity even when the accent colour is desaturated.

import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";

interface Props {
  /** The date string to render — usually `ev.hijri`, occasionally `ev.gregorian`. */
  value: string;
  onClick: () => void;
  /**
   * `"primary"` — full ink colour, italic serif at 18px (the Hijri date).
   * `"soft"` — softer ink, 16px (when annotating the Gregorian date as a
   *   fallback because no Hijri is present).
   */
  tone?: "primary" | "soft";
}

export function DisputedDateAnnotation({ value, onClick, tone = "primary" }: Props) {
  const { t } = useTranslation();
  const label = t("scholarly_views");

  return (
    <button
      type="button"
      onClick={onClick}
      title={label}
      aria-label={label}
      className={cn(
        "thaqafa-pick group inline-flex !w-auto items-baseline gap-[3px] !block cursor-help font-serif italic transition-colors",
        // Dotted underline tinted with the brand accent — the universal
        // "this term has a footnote / click for more" affordance.
        "border-b border-dotted border-accent/70 pb-[1px] hover:border-accent",
        // Hover: the date itself shifts toward accent. Keeps the editorial
        // look static-by-default, interactive-on-intent.
        "hover:text-accent",
        // Focus ring keeps the focus halo on-brand without breaking the
        // typographic alignment (no border that shifts the baseline).
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/35 focus-visible:ring-offset-2 focus-visible:ring-offset-paper",
        tone === "primary" ? "text-[18px] text-ink" : "text-[16px] text-ink-soft",
      )}
    >
      <span>{value}</span>
      <sup
        className="ml-[1px] text-[12px] not-italic leading-none text-accent transition-transform group-hover:scale-110"
        aria-hidden
      >
        †
      </sup>
    </button>
  );
}
