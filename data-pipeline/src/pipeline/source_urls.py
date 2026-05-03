"""Auto-derive verifiable source URLs from structured Quran/Hadith refs.

The mobile app surfaces a single ``source_url`` per event/lesson — a
"verify this" link that drops the reader directly on sunnah.com,
quran.com, or another canonical source. For events backed by a
``hadith_refs`` or ``quran_refs`` string we generate the URL
deterministically; for narrative events backed only by encyclopedic
material the YAML carries an explicit ``source_url`` (Wikipedia,
IslamQA, etc.) which always wins.
"""

import re

# Canonical sunnah.com slugs for the hadith collections we cite.
# Keys are lowercased name fragments; the value is the URL slug.
HADITH_COLLECTION_SLUGS: dict[str, str] = {
    "bukhari": "bukhari",
    "sahih al-bukhari": "bukhari",
    "sahih bukhari": "bukhari",
    "muslim": "muslim",
    "sahih muslim": "muslim",
    "abu dawud": "abudawud",
    "abudawud": "abudawud",
    "sunan abi dawud": "abudawud",
    "sunan abu dawud": "abudawud",
    "tirmidhi": "tirmidhi",
    "jami at-tirmidhi": "tirmidhi",
    "jami' at-tirmidhi": "tirmidhi",
    "sunan al-tirmidhi": "tirmidhi",
    "nasai": "nasai",
    "nasa'i": "nasai",
    "sunan an-nasa'i": "nasai",
    "sunan al-nasa'i": "nasai",
    "ibn majah": "ibnmajah",
    "ibnmajah": "ibnmajah",
    "sunan ibn majah": "ibnmajah",
    "ahmad": "ahmad",
    "musnad ahmad": "ahmad",
    "malik": "malik",
    "muwatta": "malik",
    "muwatta malik": "malik",
    "muwatta' malik": "malik",
    "nawawi40": "nawawi40",
    "40 hadith nawawi": "nawawi40",
    "riyad as-salihin": "riyadussalihin",
    "riyadussalihin": "riyadussalihin",
    "adab al-mufrad": "adab",
    "bulugh al-maram": "bulugh",
}

# Pattern: collection name followed by an integer hadith number.
# Captures up to and including the first hadith number in the string,
# tolerating "Bukhari 6464", "Sahih al-Bukhari 6464", etc.
_HADITH_REF_PATTERN = re.compile(
    r"(?P<collection>[A-Za-z'\- ]+?)\s+(?P<num>\d+)",
)

# Quran ref pattern: surah:ayah[-ayah]
_QURAN_REF_PATTERN = re.compile(r"(?P<surah>\d+):(?P<ayah>\d+(?:-\d+)?)")


def first_hadith_url(hadith_refs: str | None) -> str | None:
    """Return a sunnah.com URL for the first parseable hadith in ``hadith_refs``.

    Args:
        hadith_refs: Free-form citation list, e.g. ``"Bukhari 6464, Muslim 783"``
            or ``"Sahih al-Bukhari 1, Sahih Muslim 1907"``.

    Returns:
        A URL like ``"https://sunnah.com/bukhari:6464"``, or ``None`` if no
        recognised collection + number pair was found.
    """
    if not hadith_refs:
        return None
    for match in _HADITH_REF_PATTERN.finditer(hadith_refs):
        collection_raw = match.group("collection").strip().lower()
        num = match.group("num")
        slug = _resolve_collection_slug(collection_raw)
        if slug is not None:
            return f"https://sunnah.com/{slug}:{num}"
    return None


def first_quran_url(quran_refs: str | None) -> str | None:
    """Return a quran.com URL for the first verse listed in ``quran_refs``.

    Args:
        quran_refs: Free-form ref list, e.g. ``"2:255"``, ``"96:1-5"``, or
            ``"2:185, 2:186"``.

    Returns:
        A URL like ``"https://quran.com/2/255"`` or ``"https://quran.com/96/1-5"``,
        or ``None`` if no surah:ayah pair was found.
    """
    if not quran_refs:
        return None
    match = _QURAN_REF_PATTERN.search(quran_refs)
    if match is None:
        return None
    return f"https://quran.com/{match.group('surah')}/{match.group('ayah')}"


def wikidata_url(qid: str | None) -> str | None:
    """Build a wikidata.org URL for a Q-identifier.

    Args:
        qid: A Wikidata identifier like ``"Q12345"``.

    Returns:
        The full URL, or ``None`` if ``qid`` is missing or malformed.
    """
    if not qid:
        return None
    qid = qid.strip()
    if not qid.startswith("Q") or not qid[1:].isdigit():
        return None
    return f"https://www.wikidata.org/wiki/{qid}"


def derive_source_url(
    *,
    explicit: str | None,
    hadith_refs: str | None = None,
    quran_refs: str | None = None,
    wikidata_qid: str | None = None,
) -> str | None:
    """Choose the best ``source_url`` for an event/lesson.

    Precedence: explicit YAML value > sunnah.com URL from hadith_refs >
    quran.com URL from quran_refs > wikidata.org URL from Q-identifier >
    None.

    Args:
        explicit: The YAML-supplied ``source_url`` (Wikipedia / IslamQA /
            academic). Always wins when present.
        hadith_refs: The event's ``hadith_refs`` field, if any.
        quran_refs: The event's ``quran_refs`` field, if any.
        wikidata_qid: The event's Wikidata Q-identifier, if any — used as
            the final fallback for bulk-imported entries without
            scripture refs.

    Returns:
        The chosen URL, or ``None`` if nothing could be derived.
    """
    if explicit:
        return explicit
    return first_hadith_url(hadith_refs) or first_quran_url(quran_refs) or wikidata_url(wikidata_qid)


def _resolve_collection_slug(name: str) -> str | None:
    """Match a free-form collection name against the sunnah.com slug table.

    Uses longest-prefix matching so that ``"sahih al-bukhari"`` resolves to
    ``"bukhari"`` rather than failing when only ``"bukhari"`` is registered.

    Args:
        name: Lowercased, whitespace-trimmed collection fragment.

    Returns:
        The sunnah.com slug, or ``None`` if no entry matches.
    """
    if name in HADITH_COLLECTION_SLUGS:
        return HADITH_COLLECTION_SLUGS[name]
    # Try longest suffix that ends with a known short key (e.g. trailing "bukhari").
    for key in sorted(HADITH_COLLECTION_SLUGS, key=len, reverse=True):
        if name.endswith(key):
            return HADITH_COLLECTION_SLUGS[key]
    return None
