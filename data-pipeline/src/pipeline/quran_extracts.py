"""Generate ``web/public/quran-extracts.json`` — trilingual ayah text.

The frontend's *Today* page renders a centered Qur'anic epigraph above
the footer: when the day's headline event has a ``quran_refs`` field
the FE picks the first ayah and shows the trilingual text; otherwise
it falls back to **Yūsuf 12:111** ("Indeed, in their stories there is
a lesson for those of understanding"), the project's editorial
manifesto.

We don't hand-curate the verse text. We walk every event / lesson /
observance, extract every unique ``(surah, ayah)`` pair from
``quran_refs``, and call ``api.alquran.cloud`` once per verse for the
canonical Sunni trilingual editions (Tanzil ʿUṯmānī, Saheeh
International, Hamidullah). The result is a small JSON
(~100-300 verses) that the FE lazy-loads once and caches forever.

Build-time generation keeps the runtime free of any third-party
dependency — if alquran.cloud is down during a deploy we fail loudly
in CI; the live site keeps serving the previously-built JSON.
"""

import json
import re
import time
from pathlib import Path

import httpx
from loguru import logger
from sqlmodel import Session, select

from pipeline.constants import PROJECT_ROOT
from pipeline.database import session_scope
from pipeline.models.db import DatelessLesson, Event, Observance

DEFAULT_OUTPUT_DIR: Path = PROJECT_ROOT.parent / "web" / "public"

# Mirror of the pattern in :mod:`pipeline.source_urls` — only the first
# ayah of any range is fetched (display is a single concise verse).
_QURAN_REF_PATTERN = re.compile(r"(?P<surah>\d+):(?P<ayah>\d+)")

# Editorial choices, justified in CLAUDE.md (Sunni canon):
#   - quran-uthmani — Tanzil's Madinah Mushaf, full vocalisation
#   - en.sahih      — Saheeh International, Sunni-default English
#   - fr.hamidullah — Hamidullah, Sunni-default French
_EDITIONS: tuple[str, ...] = ("quran-uthmani", "en.sahih", "fr.hamidullah")
_API_BASE = "https://api.alquran.cloud/v1/ayah"

# The fixed fallback. Yūsuf 12:111 is the project's epigraph: every day
# without a directly-cited verse falls back to this one.
_FALLBACK_KEY = "12:111"

# Politeness gap between calls. alquran.cloud has no published rate
# limit but ~5/s keeps us a good citizen on a free public API.
_REQUEST_DELAY_S = 0.2


def write_quran_extracts(*, output_dir: Path | None = None, http_timeout_s: float = 10.0) -> Path:
    """Walk the DB, fetch every cited ayah, write ``quran-extracts.json``.

    Args:
        output_dir: Where to write the JSON. Defaults to ``<repo>/web/public/``.
        http_timeout_s: Per-request timeout for the alquran.cloud call.

    Returns:
        The path that was written.

    Raises:
        httpx.HTTPError: On a fetch failure that isn't a soft 404 — we
            fail the build rather than ship stale JSON.
    """
    out = output_dir or DEFAULT_OUTPUT_DIR
    out.mkdir(parents=True, exist_ok=True)
    target = out / "quran-extracts.json"

    with session_scope() as session:
        keys = _collect_unique_refs(session)
    keys.add(_FALLBACK_KEY)
    logger.info("quran-extracts: {} unique ayāt to fetch", len(keys))

    verses: dict[str, dict[str, object]] = {}
    with httpx.Client(timeout=http_timeout_s) as client:
        for key in sorted(keys, key=_sort_key):
            try:
                verses[key] = _fetch_verse(client, key)
            except httpx.HTTPError as exc:
                logger.warning("quran-extracts: skipping {} ({})", key, exc)
                continue
            time.sleep(_REQUEST_DELAY_S)

    payload = {
        "fallback": _FALLBACK_KEY,
        "attribution": {
            "ar": "Tanzil ʿUṯmānī (quran-uthmani)",
            "en": "Saheeh International",
            "fr": "Muḥammad Hamidullah",
        },
        "verses": verses,
    }
    target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    logger.info("quran-extracts: wrote {} verses → {}", len(verses), target)
    return target


def _collect_unique_refs(session: Session) -> set[str]:
    """Walk every event / lesson / observance, collect ``surah:ayah`` keys."""
    keys: set[str] = set()
    for model in (Event, DatelessLesson, Observance):
        rows = session.exec(select(model.quran_refs).where(model.quran_refs.is_not(None))).all()
        for refs in rows:
            for match in _QURAN_REF_PATTERN.finditer(refs or ""):
                keys.add(f"{match.group('surah')}:{match.group('ayah')}")
    return keys


def _fetch_verse(client: httpx.Client, key: str) -> dict[str, object]:
    """Fetch one verse in three editions; return the FE-shaped record."""
    url = f"{_API_BASE}/{key}/editions/{','.join(_EDITIONS)}"
    response = client.get(url)
    response.raise_for_status()
    body = response.json()
    if body.get("code") != 200 or "data" not in body:
        raise httpx.HTTPError(f"alquran.cloud returned non-200 body for {key}: {body.get('status')}")

    record: dict[str, object] = {}
    for entry in body["data"]:
        edition_id = entry["edition"]["identifier"]
        if edition_id == "quran-uthmani":
            record["ar"] = entry["text"]
            record["surahNameAr"] = entry["surah"]["name"]
        elif edition_id == "en.sahih":
            record["en"] = entry["text"]
            record["surahNameEn"] = entry["surah"]["englishName"]
        elif edition_id == "fr.hamidullah":
            record["fr"] = entry["text"]
        record["surahNumber"] = entry["surah"]["number"]
        record["ayahNumber"] = entry["numberInSurah"]
    return record


def _sort_key(key: str) -> tuple[int, int]:
    """Sort ``"31:13"`` numerically, not lexicographically."""
    surah, ayah = key.split(":", 1)
    return int(surah), int(ayah)


def main() -> None:
    """CLI entry point for ``python -m pipeline.quran_extracts``."""
    write_quran_extracts()


if __name__ == "__main__":
    main()
