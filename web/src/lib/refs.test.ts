// Guards the parsers that turn dataset-shaped refs ("Muslim 2963",
// "18:32-44") into clickable URLs and academic display strings. The
// dataset is hand-edited, so sloppy variants slip in — the tests
// pin the patterns we promise to handle.

import { describe, expect, it } from "vitest";
import { parseHadithRef, parseQuranRef, splitRefs } from "./refs";

describe("parseQuranRef", () => {
  it("parses a single-ayah reference", () => {
    const got = parseQuranRef("5:3");
    expect(got).toMatchObject({
      surah: 5,
      surahName: "al-Māʾida",
      ayahRange: "3",
      url: "https://quran.com/5/3",
    });
    expect(got?.display).toContain("al-Māʾida");
  });

  it("parses a verse range", () => {
    const got = parseQuranRef("18:32-44");
    expect(got?.surah).toBe(18);
    expect(got?.surahName).toBe("al-Kahf");
    expect(got?.url).toBe("https://quran.com/18/32-44");
  });

  it("rejects out-of-range surah numbers", () => {
    expect(parseQuranRef("0:1")).toBeNull();
    expect(parseQuranRef("115:1")).toBeNull();
  });

  it("rejects non-numeric input", () => {
    expect(parseQuranRef("not a ref")).toBeNull();
    expect(parseQuranRef("Bukhari 220")).toBeNull();
    expect(parseQuranRef("")).toBeNull();
  });

  it("trims whitespace around the input", () => {
    expect(parseQuranRef("  2:158  ")?.surah).toBe(2);
  });
});

describe("parseHadithRef", () => {
  it("parses bare collection + number for Bukhārī", () => {
    const got = parseHadithRef("Bukhari 2004");
    expect(got).toMatchObject({
      collectionKey: "bukhari",
      number: "2004",
      url: "https://sunnah.com/bukhari:2004",
    });
    expect(got?.display).toBe("Bukhārī 2004");
  });

  it("parses 'Sahih Muslim NNN'", () => {
    const got = parseHadithRef("Sahih Muslim 2963");
    expect(got?.collectionKey).toBe("muslim");
    expect(got?.url).toBe("https://sunnah.com/muslim:2963");
  });

  it("parses Abu Dawud / Tirmidhi / Nasa'i variants", () => {
    expect(parseHadithRef("Abu Dawud 1522")?.collectionKey).toBe("abudawud");
    expect(parseHadithRef("Sunan Abi Dawud 4753")?.collectionKey).toBe("abudawud");
    expect(parseHadithRef("Tirmidhi 889")?.collectionKey).toBe("tirmidhi");
    expect(parseHadithRef("Jami at-Tirmidhi 3747")?.collectionKey).toBe("tirmidhi");
    expect(parseHadithRef("Nasa'i 1303")?.collectionKey).toBe("nasai");
    expect(parseHadithRef("Sunan an-Nasa'i 466")?.collectionKey).toBe("nasai");
  });

  it("rejects unknown collections", () => {
    expect(parseHadithRef("XYZ 123")).toBeNull();
    expect(parseHadithRef("Made up 999")).toBeNull();
  });

  it("rejects entries that don't end with a number", () => {
    expect(parseHadithRef("Bukhari")).toBeNull();
    expect(parseHadithRef("Bukhari abc")).toBeNull();
  });
});

describe("splitRefs", () => {
  it("splits comma-separated and trims", () => {
    expect(splitRefs("Bukhari 953, Bukhari 986, Muslim 889")).toEqual([
      "Bukhari 953",
      "Bukhari 986",
      "Muslim 889",
    ]);
  });

  it("returns [] for null/undefined/empty", () => {
    expect(splitRefs(null)).toEqual([]);
    expect(splitRefs(undefined)).toEqual([]);
    expect(splitRefs("")).toEqual([]);
    expect(splitRefs("   ")).toEqual([]);
  });
});
