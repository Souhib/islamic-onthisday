"""Magic values for the API. Single home so callers don't sprinkle them inline."""

# Maximum number of secondary "on this day" entries returned in a Today payload.
TODAY_SECONDARY_LIMIT: int = 6

# Maximum number of related people / sources returned per event detail.
EVENT_PEOPLE_LIMIT: int = 12
EVENT_SOURCES_LIMIT: int = 12

# Importance tiers eligible for the Today *headline* slot. Bulk imports land
# at ``importance="minor"`` and are deliberately excluded — the headline is
# only ever a curated, named-by-the-editor event.
HEADLINE_IMPORTANCE: tuple[str, ...] = ("major", "notable")

# Importance ladder used internally by Today picker fallback. Earlier wins.
IMPORTANCE_PRIORITY: tuple[str, ...] = ("major", "notable", "minor")

# Verification statuses eligible for the headline slot. ``unverified`` (the
# default for Wikidata + OpenITI bulk imports) is excluded — we never put a
# bulk-imported event in the headline, even if it happens to be tagged
# ``importance="major"`` for some reason.
HEADLINE_VERIFICATION_STATUSES: frozenset[str] = frozenset({"single_source", "cross_verified", "scholar_reviewed"})

# A Hijri month-day key, encoded as ``month * 100 + day`` for compact indexing.
HIJRI_MD_FACTOR: int = 100

# Hijri month names — single source of truth, shared between the Today
# calendar projection, the disputed-position formatter, and (via the OpenAPI
# schema) the front-end's filter UI. ``_LONG`` is the full liturgical form
# (used in the calendar masthead); ``_SHORT`` drops the connectives.
HIJRI_MONTH_NAMES_LONG: tuple[str, ...] = (
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
)
HIJRI_MONTH_NAMES_SHORT: tuple[str, ...] = (
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
)

GREGORIAN_MONTH_NAMES: tuple[str, ...] = (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)
WEEKDAY_NAMES: tuple[str, ...] = (
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
)
