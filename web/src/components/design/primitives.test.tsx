import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { VerificationChip, isVerificationKind } from "./primitives";

describe("VerificationChip", () => {
  it("renders the supplied label verbatim", () => {
    const { rerender } = render(<VerificationChip kind="cross_verified" label="Cross-verified" />);
    expect(screen.getByText("Cross-verified")).toBeInTheDocument();

    rerender(<VerificationChip kind="single_source" label="Single source" />);
    expect(screen.getByText("Single source")).toBeInTheDocument();

    rerender(<VerificationChip kind="unverified" label="Unverified" />);
    expect(screen.getByText("Unverified")).toBeInTheDocument();
  });
});

describe("isVerificationKind", () => {
  it("accepts every snake_case ladder value", () => {
    expect(isVerificationKind("scholar_reviewed")).toBe(true);
    expect(isVerificationKind("cross_verified")).toBe(true);
    expect(isVerificationKind("single_source")).toBe(true);
    expect(isVerificationKind("auto_verified")).toBe(true);
    expect(isVerificationKind("unverified")).toBe(true);
  });

  it("rejects the legacy kebab-case form, the empty string, and undefined", () => {
    expect(isVerificationKind("cross-verified")).toBe(false);
    expect(isVerificationKind("")).toBe(false);
    expect(isVerificationKind(undefined)).toBe(false);
    expect(isVerificationKind(null)).toBe(false);
  });
});
