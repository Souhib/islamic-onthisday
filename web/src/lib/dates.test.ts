import { describe, expect, it } from "vitest";
import { formatGregorianDDMMYYYY, formatGregorianLong } from "./dates";

describe("formatGregorianLong", () => {
  it("renders English as '5 May 1030'", () => {
    expect(formatGregorianLong("1030-05-06", "en")).toBe("6 May 1030");
  });

  it("renders French as '6 mai 1030'", () => {
    expect(formatGregorianLong("1030-05-06", "fr")).toMatch(/^6 mai 1030$/);
  });

  it("handles a 7th-century date", () => {
    // Death of the Prophet ﷺ — 8 June 632 CE.
    expect(formatGregorianLong("0632-06-08", "en")).toBe("8 June 632");
  });

  it("returns the input unchanged on a bad format", () => {
    expect(formatGregorianLong("not-a-date", "en")).toBe("not-a-date");
  });
});

describe("formatGregorianDDMMYYYY", () => {
  it("flips ISO to DD-MM-YYYY", () => {
    expect(formatGregorianDDMMYYYY("1030-05-06")).toBe("06-05-1030");
  });

  it("pads a 3-digit year to four", () => {
    expect(formatGregorianDDMMYYYY("0632-06-08")).toBe("08-06-0632");
  });

  it("returns the input unchanged on a bad format", () => {
    expect(formatGregorianDDMMYYYY("not-a-date")).toBe("not-a-date");
  });
});
