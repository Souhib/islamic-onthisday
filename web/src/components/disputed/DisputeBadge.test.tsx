import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import "@/i18n"; // i18next bootstrap so useTranslation has resources
import { DisputeBadge } from "./DisputeBadge";

describe("DisputeBadge", () => {
  it("renders the date-dispute label by default for disputeAbout=date", async () => {
    render(<DisputeBadge disputeAbout="date" />);
    // i18n loads asynchronously — await text appearing.
    expect(await screen.findByText(/date varies|date varies across sources/i)).toBeInTheDocument();
  });

  it("falls back to the generic 'scholarly views differ' label when disputeAbout is null", async () => {
    render(<DisputeBadge disputeAbout={null} />);
    expect(await screen.findByText(/scholarly views/i)).toBeInTheDocument();
  });

  it("renders as a button when onClick is supplied", () => {
    render(<DisputeBadge disputeAbout="date" onClick={() => {}} />);
    expect(screen.getByRole("button")).toBeInTheDocument();
  });

  it("renders as a span when onClick is omitted", () => {
    render(<DisputeBadge disputeAbout="date" />);
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("honours an explicit label override", () => {
    render(<DisputeBadge disputeAbout="date" label="Custom" />);
    expect(screen.getByText("Custom")).toBeInTheDocument();
  });
});
