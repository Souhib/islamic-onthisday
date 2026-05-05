"""OpenITI metadata ingestion.

Pulls machine-readable author metadata from the OpenITI
`kitab-metadata-automation` repo. Each entry carries an AuthorID that encodes
a Hijri death year (for example `0256Bukhari` = al-Bukhari, d. 256 AH). The
year of death is reliable, but month and day granularity are not present in
the released JSON, so every OpenITI-derived event is year-precision.

OpenITI is cross-linked to Wikidata via Wikidata property P13870 (OpenITI
author ID) so shared entities end up with both QIDs on the same row when
Wikidata-first ingestion precedes OpenITI.
"""

import json
import re

import httpx
from rich.console import Console
from slugify import slugify
from sqlmodel import Session, select

from pipeline.constants import (
    OPENITI_HTTP_TIMEOUT,
    OPENITI_MAX_HIJRI_YEAR,
    OPENITI_META_URL,
    OPENITI_MIN_HIJRI_YEAR,
)
from pipeline.models.db import DateClaim, Event, Person, Source
from pipeline.schemas.inputs import EventCategory

console = Console()

_AUTHOR_ID_RE = re.compile(r"^(\d{4})([A-Za-z].*)$")
_OPENITI_NAME_KEYS: tuple[str, ...] = (
    "author_lat",
    "author_ar_prefered",
    "name",
    "shuhra",
)
_OPENITI_QID_KEYS: tuple[str, ...] = (
    "wikidata",
    "wikidata_id",
    "P13870_wd",
    "wikidata_qid",
)


def _coerce_scalar(value: object) -> object | None:
    """Return the first element of a list-valued field, or the value itself.

    OpenITI metadata occasionally ships string values wrapped in a single-item
    list. SQLite cannot bind list parameters, so we flatten before insert.

    Args:
        value: A raw metadata value from the OpenITI JSON feed.

    Returns:
        The scalar form of the input, or None if the input is empty.
    """
    if value is None:
        return None
    if isinstance(value, list):
        return value[0] if value else None
    return value


def _get_openiti_source(session: Session) -> Source:
    """Fetch or create the canonical OpenITI :class:`Source` row.

    Args:
        session: An open SQLAlchemy session.

    Returns:
        The persisted Source record keyed by "openiti".
    """
    src = session.exec(select(Source).where(Source.key == "openiti")).first()
    if src is not None:
        return src
    src = Source(
        key="openiti",
        name="OpenITI (Open Islamicate Texts Initiative)",
        url="https://openiti.org/",
        era="modern_academic",
        notes="Machine-readable scholar metadata. Hijri death year in AuthorID.",
    )
    session.add(src)
    session.flush()
    return src


def _parse_author_id(author_id: str) -> tuple[int, str] | None:
    """Split an OpenITI AuthorID of the form ``YYYYShuhra`` into parts.

    Args:
        author_id: The raw AuthorID (e.g. ``"0256Bukhari"``).

    Returns:
        A tuple of (hijri_year, shuhra) if the ID matches the expected format, or None otherwise.
    """
    match = _AUTHOR_ID_RE.match(author_id)
    if not match:
        return None
    return int(match.group(1)), match.group(2)


def _extract_name_and_qid(info: object) -> tuple[str | None, str | None]:
    """Pull the Latin-script name and Wikidata QID out of one OpenITI entry.

    Args:
        info: The per-author dict (or other shape) from the JSON feed.

    Returns:
        A ``(name, wikidata_qid)`` tuple. Either element may be None.
    """
    if not isinstance(info, dict):
        return None, None

    name: str | None = None
    for key in _OPENITI_NAME_KEYS:
        raw = _coerce_scalar(info.get(key))
        if raw:
            name = str(raw)
            break

    qid: str | None = None
    for key in _OPENITI_QID_KEYS:
        raw = _coerce_scalar(info.get(key))
        if not raw:
            continue
        candidate = str(raw).strip()
        if candidate.startswith("http"):
            candidate = candidate.rsplit("/", 1)[-1]
        qid = candidate
        break

    return name, qid


def _fetch_metadata() -> dict | list:
    """Download the OpenITI author metadata JSON blob.

    Returns:
        The decoded JSON structure. Returns an empty dict on failure so callers can proceed with partial data.
    """
    try:
        resp = httpx.get(OPENITI_META_URL, timeout=OPENITI_HTTP_TIMEOUT)
        resp.raise_for_status()
    except httpx.HTTPError as exc:
        console.log(f"[red]OpenITI fetch failed: {exc}[/]")
        return {}

    content_type = resp.headers.get("content-type", "")
    if content_type.startswith("application/json"):
        return resp.json()
    return json.loads(resp.text)


def _normalise_items(data: dict | list) -> list[tuple[str, object]] | None:
    """Coerce the raw OpenITI payload into a ``[(author_id, info), ...]`` list.

    Args:
        data: Decoded JSON feed (dict-of-dicts or list-of-dicts).

    Returns:
        Normalised list or ``None`` on unexpected structure.
    """
    if isinstance(data, dict):
        return list(data.items())
    if isinstance(data, list):
        return [(str(item.get("author_id") or item.get("AuthorID") or ""), item) for item in data]
    return None


def _insert_author_person(
    session: Session, *, author_id: str, name: str, shuhra: str, qid: str | None
) -> Person | None:
    """Create a Person row for a new OpenITI author. Returns None if slug collides.

    Args:
        session: Open SQLAlchemy session.
        author_id: OpenITI AuthorID string.
        name: Latin-script author name.
        shuhra: Short-form name (used for slug).
        qid: Optional Wikidata QID cross-link.

    Returns:
        Persisted Person row, or None if a slug collision prevents insert.
    """
    person_slug = f"oi-{slugify(shuhra)}-{author_id[:4]}"[:128]
    if session.exec(select(Person).where(Person.slug == person_slug)).first() is not None:
        return None
    person = Person(
        slug=person_slug,
        full_name_en=name,
        openiti_id=author_id,
        wikidata_qid=qid,
        is_sahabi=False,
        is_prophet=False,
        is_ahl_al_bayt=False,
    )
    session.add(person)
    session.flush()
    return person


def _insert_author_death_event(
    session: Session,
    *,
    src: Source,
    author_id: str,
    name: str,
    shuhra: str,
    hijri_year: int,
) -> bool:
    """Insert a year-precision ``scholar_death`` event for an OpenITI author.

    Args:
        session: Open SQLAlchemy session.
        src: Cached OpenITI source record.
        author_id: OpenITI AuthorID string.
        name: Author's full name.
        shuhra: Short-form name for slug construction.
        hijri_year: Hijri year of death (from AuthorID).

    Returns:
        ``True`` if the event was inserted, ``False`` if the slug already existed.
    """
    event_slug = f"oi-death-{slugify(shuhra)}-{hijri_year}"[:160]
    if session.exec(select(Event).where(Event.slug == event_slug)).first() is not None:
        return False
    event = Event(
        slug=event_slug,
        category=EventCategory.SCHOLAR_DEATH.value,
        title_en=f"Death of {name} (d. {hijri_year} AH)",
        description_en=(
            f"{name} is recorded in the Open Islamicate Texts Initiative "
            f"(AuthorID {author_id}) with a Hijri death year of {hijri_year}. "
            f"Month- and day-level precision is not available in OpenITI "
            f"metadata; this entry should be treated as a 'this Hijri year' "
            f"record, not a day-precise event."
        ),
        canonical_hijri_year=hijri_year,
        canonical_hijri_precision="year",
        importance="minor",
        verification_status="unverified",
        verified=False,
    )
    session.add(event)
    session.flush()
    session.add(
        DateClaim(
            event_id=event.id,
            source_id=src.id,
            hijri_year=hijri_year,
            hijri_precision="year",
            is_canonical=True,
        )
    )
    return True


def _process_one_author(
    session: Session,
    *,
    src: Source,
    author_id: str,
    info: object,
    existing_by_openiti: dict[str, Person],
    counts: dict[str, int],
) -> None:
    """Handle a single (author_id, info) tuple from the OpenITI feed.

    Args:
        session: Open SQLAlchemy session.
        src: Cached OpenITI source row.
        author_id: Raw author ID from feed.
        info: Associated author metadata dict.
        existing_by_openiti: Lookup of already-persisted authors.
        counts: Accumulator dict mutated in place.
    """
    parsed = _parse_author_id(author_id)
    if parsed is None:
        return
    hijri_year, shuhra = parsed
    if not (OPENITI_MIN_HIJRI_YEAR <= hijri_year <= OPENITI_MAX_HIJRI_YEAR):
        return

    name, wikidata_qid = _extract_name_and_qid(info)
    name = name or shuhra

    existing = existing_by_openiti.get(author_id)
    if existing is not None:
        if wikidata_qid and not existing.wikidata_qid:
            existing.wikidata_qid = wikidata_qid
            counts["persons_updated"] += 1
        return

    person = _insert_author_person(session, author_id=author_id, name=name, shuhra=shuhra, qid=wikidata_qid)
    if person is None:
        return
    counts["persons_added"] += 1

    if _insert_author_death_event(
        session, src=src, author_id=author_id, name=name, shuhra=shuhra, hijri_year=hijri_year
    ):
        counts["events_added"] += 1


def ingest(session: Session, limit: int | None = None) -> dict[str, int]:
    """Ingest the OpenITI author metadata into the database.

    Args:
        session: An open SQLAlchemy session.
        limit: Optional cap on the number of authors processed.

    Returns:
        Dict with counts of persons added/updated and events added.
    """
    counts: dict[str, int] = {"persons_added": 0, "persons_updated": 0, "events_added": 0}

    src = _get_openiti_source(session)
    console.log("[cyan]Fetching OpenITI author metadata…[/]")
    items = _normalise_items(_fetch_metadata())
    if items is None:
        console.log("[red]Unexpected OpenITI JSON structure.[/]")
        return counts

    existing_by_openiti: dict[str, Person] = {
        person.openiti_id: person for person in session.exec(select(Person).where(Person.openiti_id.isnot(None))).all()
    }

    processed = 0
    for author_id, info in items:
        if limit is not None and processed >= limit:
            break
        if not author_id:
            continue
        processed += 1
        _process_one_author(
            session,
            src=src,
            author_id=author_id,
            info=info,
            existing_by_openiti=existing_by_openiti,
            counts=counts,
        )

    session.flush()
    return counts
