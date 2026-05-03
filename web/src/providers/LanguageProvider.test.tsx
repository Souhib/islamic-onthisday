import { describe, expect, it } from "vitest";
import { pickLocalised, pickLocalisedList } from "./LanguageProvider";

describe("pickLocalised", () => {
  it("returns the requested language when available", () => {
    expect(pickLocalised({ en: "Hi", fr: "Salut", ar: "مرحبا" }, "fr")).toBe("Salut");
    expect(pickLocalised({ en: "Hi", fr: "Salut", ar: "مرحبا" }, "ar")).toBe("مرحبا");
    expect(pickLocalised({ en: "Hi", fr: "Salut", ar: "مرحبا" }, "en")).toBe("Hi");
  });

  it("falls back to English when the requested language is missing", () => {
    expect(pickLocalised({ en: "Hi", fr: null, ar: undefined }, "fr")).toBe("Hi");
    expect(pickLocalised({ en: "Hi" }, "ar")).toBe("Hi");
  });

  it("returns undefined when neither requested nor English is set", () => {
    expect(pickLocalised({ en: null }, "fr")).toBeUndefined();
    expect(pickLocalised({ en: null, fr: null, ar: null }, "ar")).toBeUndefined();
  });

  it("ignores empty-string fallbacks the same way as null", () => {
    // Empty string is falsy — caller probably means "no translation".
    expect(pickLocalised({ en: "Hi", fr: "" }, "fr")).toBe("Hi");
  });
});

describe("pickLocalisedList", () => {
  it("returns the requested-language list when populated", () => {
    expect(pickLocalisedList({ en: ["a"], fr: ["b"] }, "fr")).toEqual(["b"]);
  });

  it("falls back to English when the requested list is empty or missing", () => {
    expect(pickLocalisedList({ en: ["a"], fr: [] }, "fr")).toEqual(["a"]);
    expect(pickLocalisedList({ en: ["a"], fr: null }, "fr")).toEqual(["a"]);
    expect(pickLocalisedList({ en: ["a"] }, "ar")).toEqual(["a"]);
  });
});
