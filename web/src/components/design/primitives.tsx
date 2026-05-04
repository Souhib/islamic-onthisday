// Editorial design primitives — eight-point star, hairline rule, frieze
// rosette, verification dot-chip, placeholder image plates.
//
// All visual styling flows through Tailwind utilities backed by the CSS
// variables in `src/index.css`. Dark mode flips via the `dark` class on
// `<html>` (toggled by `ThemeProvider`); no component branches on it.

import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";

interface CommonProps {
  className?: string;
}

export function EightPointStar({
  size = 18,
  className,
  strokeWidth = 0.8,
}: {
  size?: number;
  className?: string;
  strokeWidth?: number;
}) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" className={cn("shrink-0", className)}>
      <g fill="none" stroke="currentColor" strokeWidth={strokeWidth} strokeLinejoin="round">
        <rect x="4" y="4" width="16" height="16" />
        <rect x="4" y="4" width="16" height="16" transform="rotate(45 12 12)" />
      </g>
    </svg>
  );
}

export function Rule({ soft = false, className }: CommonProps & { soft?: boolean }) {
  return <div className={cn("h-[0.5px]", soft ? "bg-rule-soft" : "bg-rule", className)} />;
}

export function Eyebrow({
  children,
  color,
  className,
}: CommonProps & { children: React.ReactNode; color?: "ink-mute" | "accent" | "warn" | "ink" }) {
  const colorClass =
    color === "accent"
      ? "text-accent"
      : color === "warn"
        ? "text-warn"
        : color === "ink"
          ? "text-ink"
          : "text-ink-mute";
  return (
    <span className={cn("font-mono text-[12px] uppercase tracking-[1.4px]", colorClass, className)}>
      {children}
    </span>
  );
}

interface FriezeProps extends CommonProps {
  label?: string;
  marginTop?: number;
  marginBottom?: number;
  /** Renders just the centred rosette (no label, no rules). */
  rosetteOnly?: boolean;
}

function Rosette() {
  return (
    <svg width="22" height="22" viewBox="0 0 22 22" className="block text-accent">
      <g fill="none" stroke="currentColor" strokeWidth="0.6">
        <circle cx="11" cy="11" r="8.5" />
        <circle cx="11" cy="11" r="4.5" />
        <rect x="4.5" y="4.5" width="13" height="13" />
        <rect x="4.5" y="4.5" width="13" height="13" transform="rotate(45 11 11)" />
      </g>
    </svg>
  );
}

export function FriezeRule({
  label,
  marginTop = 22,
  marginBottom = 18,
  rosetteOnly = false,
}: FriezeProps) {
  if (rosetteOnly) {
    return (
      <div className="flex justify-center" style={{ marginTop, marginBottom }}>
        <Rosette />
      </div>
    );
  }
  return (
    <div className="relative" style={{ marginTop, marginBottom }}>
      <div className="h-px bg-ink opacity-85" />
      <div className="mt-[3px] h-[0.5px] bg-rule" />
      <div className="absolute -top-[10px] left-1/2 flex -translate-x-1/2 items-center gap-2.5 bg-paper px-2.5">
        <Rosette />
        {label && (
          <span className="whitespace-nowrap font-mono text-[11.5px] uppercase tracking-[2px] text-accent">
            {label}
          </span>
        )}
        {label && <Rosette />}
      </div>
    </div>
  );
}

const VERIFICATION_TIERS = {
  scholar_reviewed: { dots: 4, tone: "accent" as const },
  cross_verified: { dots: 3, tone: "accent" as const },
  auto_verified: { dots: 2, tone: "accent" as const },
  single_source: { dots: 2, tone: "warn" as const },
  unverified: { dots: 1, tone: "warn" as const },
} as const;

export type VerificationKind = keyof typeof VERIFICATION_TIERS;

export const VERIFICATION_KINDS = Object.keys(VERIFICATION_TIERS) as VerificationKind[];

export function isVerificationKind(value: unknown): value is VerificationKind {
  return typeof value === "string" && value in VERIFICATION_TIERS;
}

export function VerificationChip({
  kind,
  size = "sm",
  label,
  className,
}: CommonProps & { kind: VerificationKind; size?: "xs" | "sm"; label?: string }) {
  const tier = VERIFICATION_TIERS[kind];
  const tone = tier.tone === "warn" ? "text-warn" : "text-accent";
  const sizeClass = size === "xs" ? "text-[11.5px]" : "text-[12.5px]";
  const { t } = useTranslation();
  const tooltipKey = `verification_tooltip_${kind}` as const;
  const tooltip = t(tooltipKey, "");
  return (
    <span
      title={tooltip || undefined}
      className={cn(
        "inline-flex cursor-help items-center gap-1.5 font-mono uppercase tracking-[0.5px]",
        tone,
        sizeClass,
        className,
      )}
    >
      <span className="inline-flex gap-[2px]">
        {[0, 1, 2, 3].map((i) => {
          const filled = i < tier.dots;
          return (
            <span
              key={i}
              className={cn(
                "h-1 w-1 border border-current",
                filled ? "bg-current opacity-100" : "bg-transparent opacity-[0.35]",
              )}
            />
          );
        })}
      </span>
      {label}
    </span>
  );
}

export function PlaceholderImage({
  caption,
  height = 180,
  className,
}: CommonProps & { caption: string; height?: number }) {
  return (
    <div
      className={cn(
        "relative overflow-hidden bg-paper-lo",
        "[background:repeating-linear-gradient(90deg,rgba(27,26,23,0.04)_0_8px,rgba(27,26,23,0.07)_8px_16px),var(--paper-lo)]",
        "dark:[background:repeating-linear-gradient(90deg,rgba(237,230,210,0.04)_0_8px,rgba(237,230,210,0.07)_8px_16px),var(--paper-hi)]",
        className,
      )}
      style={{ height }}
    >
      <div className="absolute left-0 right-0 top-[62%] h-[0.5px] bg-ink/10 dark:bg-ink/[0.12]" />
      <div className="absolute bottom-3 left-3.5 right-3.5 flex items-baseline justify-between">
        <span className="font-mono text-[11.5px] tracking-[0.6px] text-ink-mute lowercase">
          {caption}
        </span>
        <span className="font-mono text-[8.5px] tracking-[0.6px] text-ink-faint">placeholder</span>
      </div>
    </div>
  );
}

export function NoImagePlate({
  caption = "no plate · this account survives in text only",
  height = 170,
  glyph,
  className,
}: CommonProps & { caption?: string; height?: number; glyph?: string }) {
  const corners = [
    "top-2 left-2 border-t border-l",
    "top-2 right-2 border-t border-r",
    "bottom-2 left-2 border-b border-l",
    "bottom-2 right-2 border-b border-r",
  ];
  return (
    <div
      className={cn(
        "relative flex items-center justify-center overflow-hidden",
        "border-t border-b border-rule-soft bg-paper-hi",
        className,
      )}
      style={{ height }}
    >
      {corners.map((position) => (
        <div key={position} className={cn("absolute h-2.5 w-2.5 border-rule-soft", position)} />
      ))}
      <div className="absolute left-7 right-[62%] top-1/2 h-[0.5px] bg-rule-soft" />
      <div className="absolute right-7 left-[62%] top-1/2 h-[0.5px] bg-rule-soft" />

      <div className="relative z-[1] flex h-16 w-16 items-center justify-center bg-paper-hi">
        {glyph ? (
          <span className="font-serif text-[48px] italic leading-none text-ink-faint">{glyph}</span>
        ) : (
          <EightPointStar size={36} className="text-ink-faint" strokeWidth={0.6} />
        )}
      </div>
      <span className="absolute bottom-2.5 left-4 font-mono text-[11.5px] tracking-[0.6px] text-ink-faint lowercase">
        {caption}
      </span>
      <span className="absolute right-4 top-2.5 font-mono text-[8.5px] tracking-[1.2px] text-ink-faint uppercase">
        · text only ·
      </span>
    </div>
  );
}

