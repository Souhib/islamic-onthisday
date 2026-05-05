// Parsing helpers for Qurʾān + ḥadīth references in the dataset. The
// dataset stores them as compact strings ("18:32-44", "Muslim 2963")
// and the FE turns them into:
//   - a clickable URL pointing at quran.com / sunnah.com,
//   - a richer display string that prepends the Surah name or hadith
//     collection name in academic transliteration.

export const SURAH_NAMES: Record<number, string> = {
  1: "al-Fātiḥa",
  2: "al-Baqara",
  3: "Āl ʿImrān",
  4: "al-Nisāʾ",
  5: "al-Māʾida",
  6: "al-Anʿām",
  7: "al-Aʿrāf",
  8: "al-Anfāl",
  9: "al-Tawba",
  10: "Yūnus",
  11: "Hūd",
  12: "Yūsuf",
  13: "al-Raʿd",
  14: "Ibrāhīm",
  15: "al-Ḥijr",
  16: "al-Naḥl",
  17: "al-Isrāʾ",
  18: "al-Kahf",
  19: "Maryam",
  20: "Ṭā Hā",
  21: "al-Anbiyāʾ",
  22: "al-Ḥajj",
  23: "al-Muʾminūn",
  24: "al-Nūr",
  25: "al-Furqān",
  26: "al-Shuʿarāʾ",
  27: "al-Naml",
  28: "al-Qaṣaṣ",
  29: "al-ʿAnkabūt",
  30: "al-Rūm",
  31: "Luqmān",
  32: "al-Sajda",
  33: "al-Aḥzāb",
  34: "Sabaʾ",
  35: "Fāṭir",
  36: "Yā Sīn",
  37: "al-Ṣāffāt",
  38: "Ṣād",
  39: "al-Zumar",
  40: "Ghāfir",
  41: "Fuṣṣilat",
  42: "al-Shūrā",
  43: "al-Zukhruf",
  44: "al-Dukhān",
  45: "al-Jāthiya",
  46: "al-Aḥqāf",
  47: "Muḥammad",
  48: "al-Fatḥ",
  49: "al-Ḥujurāt",
  50: "Qāf",
  51: "al-Dhāriyāt",
  52: "al-Ṭūr",
  53: "al-Najm",
  54: "al-Qamar",
  55: "al-Raḥmān",
  56: "al-Wāqiʿa",
  57: "al-Ḥadīd",
  58: "al-Mujādila",
  59: "al-Ḥashr",
  60: "al-Mumtaḥana",
  61: "al-Ṣaff",
  62: "al-Jumuʿa",
  63: "al-Munāfiqūn",
  64: "al-Taghābun",
  65: "al-Ṭalāq",
  66: "al-Taḥrīm",
  67: "al-Mulk",
  68: "al-Qalam",
  69: "al-Ḥāqqa",
  70: "al-Maʿārij",
  71: "Nūḥ",
  72: "al-Jinn",
  73: "al-Muzzammil",
  74: "al-Muddaththir",
  75: "al-Qiyāma",
  76: "al-Insān",
  77: "al-Mursalāt",
  78: "al-Nabaʾ",
  79: "al-Nāziʿāt",
  80: "ʿAbasa",
  81: "al-Takwīr",
  82: "al-Infiṭār",
  83: "al-Muṭaffifīn",
  84: "al-Inshiqāq",
  85: "al-Burūj",
  86: "al-Ṭāriq",
  87: "al-Aʿlā",
  88: "al-Ghāshiya",
  89: "al-Fajr",
  90: "al-Balad",
  91: "al-Shams",
  92: "al-Layl",
  93: "al-Ḍuḥā",
  94: "al-Sharḥ",
  95: "al-Tīn",
  96: "al-ʿAlaq",
  97: "al-Qadr",
  98: "al-Bayyina",
  99: "al-Zalzala",
  100: "al-ʿĀdiyāt",
  101: "al-Qāriʿa",
  102: "al-Takāthur",
  103: "al-ʿAṣr",
  104: "al-Humaza",
  105: "al-Fīl",
  106: "Quraysh",
  107: "al-Māʿūn",
  108: "al-Kawthar",
  109: "al-Kāfirūn",
  110: "al-Naṣr",
  111: "al-Masad",
  112: "al-Ikhlāṣ",
  113: "al-Falaq",
  114: "al-Nās",
};

export interface QuranRef {
  raw: string;
  surah: number;
  surahName: string;
  ayahRange: string;
  url: string;
  display: string;
}

/**
 * Parse a Qurʾān reference like "18:32-44" or "5:3" into a structured
 * object with the Surah name + a quran.com URL. Returns null for any
 * input that doesn't match the canonical surah:ayah(-ayah)? shape.
 */
export function parseQuranRef(ref: string): QuranRef | null {
  const raw = ref.trim();
  const match = raw.match(/^(\d{1,3}):([\d\-,]+)$/);
  if (!match) return null;
  const surah = Number.parseInt(match[1], 10);
  const ayahRange = match[2];
  if (!Number.isFinite(surah) || surah < 1 || surah > 114) return null;
  const surahName = SURAH_NAMES[surah];
  return {
    raw,
    surah,
    surahName,
    ayahRange,
    url: `https://quran.com/${surah}/${ayahRange.replace(/,/g, ",")}`,
    display: `${surahName} · ${raw}`,
  };
}

export interface HadithRef {
  raw: string;
  collection: string;
  collectionKey: string;
  number: string;
  url: string;
  display: string;
}

// Maps the variant strings the dataset uses to the sunnah.com slug + a
// canonical academic display. Order matters — first match wins, so the
// more-specific patterns come first.
const HADITH_COLLECTIONS: Array<{ pattern: RegExp; key: string; display: string }> = [
  { pattern: /^(?:sahih\s+)?al[-\s]?bukh[āa]r[īi]?$/i, key: "bukhari", display: "Bukhārī" },
  { pattern: /^(?:sahih\s+)?bukh[āa]r[īi]?$/i, key: "bukhari", display: "Bukhārī" },
  { pattern: /^(?:sahih\s+)?muslim$/i, key: "muslim", display: "Muslim" },
  { pattern: /^(?:sunan\s+)?ab[īi]?\s+d[āa][wu][uo]d$/i, key: "abudawud", display: "Abū Dāwūd" },
  { pattern: /^(?:sunan\s+)?abu\s+d[aā][wu][uo]d$/i, key: "abudawud", display: "Abū Dāwūd" },
  {
    pattern: /^(?:j[āa]mi['ʿ`]?\s+(?:at[-\s]?)?)?(?:al[-\s]?)?tirmidh[īi]?$/i,
    key: "tirmidhi",
    display: "al-Tirmidhī",
  },
  {
    pattern: /^(?:sunan\s+)?(?:an[-\s]?|al[-\s]?)?nas[āa]['ʾ`]?[īi]?$/i,
    key: "nasai",
    display: "al-Nasāʾī",
  },
  { pattern: /^(?:sunan\s+)?ibn\s+m[āa]jah$/i, key: "ibnmajah", display: "Ibn Mājah" },
  { pattern: /^(?:musnad\s+)?(?:ahmad|aḥmad)$/i, key: "ahmad", display: "Aḥmad" },
  { pattern: /^(?:al[-\s]?)?muwa[ṭt]+a['ʾ`]?$/i, key: "malik", display: "Mālik" },
  { pattern: /^d[āa]rim[īi]?$/i, key: "darimi", display: "al-Dārimī" },
  {
    pattern: /^riy[āa]d(?:\s+(?:as|us)[-\s]?)?[sṣ][āa][lḷ]i[ḥh][īi]n$/i,
    key: "riyadussalihin",
    display: "Riyāḍ al-Ṣāliḥīn",
  },
];

/**
 * Parse a ḥadīth reference like "Bukhari 2004" or "Sahih Muslim 1162"
 * into a structured object with the canonical collection name + a
 * sunnah.com URL. Returns null for any input that doesn't end in a
 * number or whose collection isn't recognised.
 */
export function parseHadithRef(ref: string): HadithRef | null {
  const raw = ref.trim();
  const match = raw.match(/^(.+?)\s+(\d+)$/);
  if (!match) return null;
  const collectionRaw = match[1].trim();
  const number = match[2];
  const found = HADITH_COLLECTIONS.find(({ pattern }) => pattern.test(collectionRaw));
  if (!found) return null;
  return {
    raw,
    collection: found.display,
    collectionKey: found.key,
    number,
    url: `https://sunnah.com/${found.key}:${number}`,
    display: `${found.display} ${number}`,
  };
}

/**
 * Split a comma-separated reference string into trimmed pieces.
 * Empty results filtered out.
 */
export function splitRefs(refs: string | null | undefined): string[] {
  if (!refs) return [];
  return refs
    .split(",")
    .map((r) => r.trim())
    .filter(Boolean);
}
