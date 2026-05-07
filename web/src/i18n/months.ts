// Hijri month names — single source of truth for the front-end.
// Backend exposes the same constants in `thaqafa/api/constants.py`; the order
// is identical so a backend index lookup matches a frontend array index.

export const HIJRI_MONTHS_LONG = [
  "Muḥarram",
  "Ṣafar",
  "Rabīʿ al-Awwal",
  "Rabīʿ al-Thānī",
  "Jumādā al-Ūlā",
  "Jumādā al-Ākhirah",
  "Rajab",
  "Shaʿbān",
  "Ramaḍān",
  "Shawwāl",
  "Dhū al-Qaʿda",
  "Dhū al-Ḥijja",
] as const;

export const HIJRI_MONTHS_SHORT = [
  "Muḥarram",
  "Ṣafar",
  "Rabīʿ I",
  "Rabīʿ II",
  "Jumādā I",
  "Jumādā II",
  "Rajab",
  "Shaʿbān",
  "Ramaḍān",
  "Shawwāl",
  "Dhū al-Qaʿda",
  "Dhū al-Ḥijja",
] as const;
