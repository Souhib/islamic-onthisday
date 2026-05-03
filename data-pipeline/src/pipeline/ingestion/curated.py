"""Curated YAML ingestion — highest-trust source.

Reads hand-written content from ``data/curated/``:

* ``sources.yaml`` — citable references.
* ``people.yaml`` — historical figures (with religious-prohibition flags).
* ``events/*.yaml`` — dated historical events, split by era for
  maintainability. Every ``.yaml`` file in this directory is loaded.
* ``lessons/*.yaml`` — dateless Quran/Sunnah content. Each lesson must carry
  a unique ``display_day_of_year`` across all files.

Cross-references between events and people/sources are resolved by
slug/key. Anything referencing a missing slug is logged but not fatal.
"""

from datetime import date as _date
from pathlib import Path

import yaml
from rich.console import Console
from sqlmodel import Session, select

from pipeline.constants import (
    CURATED_DIR,
    CURATED_EVENTS_DIR,
    CURATED_LESSONS_DIR,
)
from pipeline.conversion import greg_doy, hijri_md_key, hijri_to_gregorian
from pipeline.models.db import (
    DateClaim,
    DatelessLesson,
    Event,
    EventPerson,
    EventTag,
    Observance,
    Person,
    Source,
    Tag,
)
from pipeline.schemas import GregorianDate, HijriDate, Precision
from pipeline.source_urls import derive_source_url

console = Console()


def _parse_date_maybe(value: object) -> _date | None:
    """Accept a :class:`datetime.date` or an ISO-like string with any year width.

    Python's :meth:`date.fromisoformat` rejects 3-digit years, so this helper
    splits on ``-`` and constructs the date directly — which works for any
    positive year (including the 7th-century CE values we need for early
    Islamic history).

    Args:
        value: Either a Python ``date`` or a ``YYYY-MM-DD`` / ``YYY-MM-DD`` / ``YY-MM-DD`` string.

    Returns:
        The parsed ``date``, or None if the input is missing or malformed.
    """
    if value is None:
        return None
    if isinstance(value, _date):
        return value
    parts = str(value).split("-")
    if len(parts) != 3:
        return None
    try:
        return _date(int(parts[0]), int(parts[1]), int(parts[2]))
    except ValueError:
        return None


def _parse_hijri(data: dict | None) -> HijriDate | None:
    """Convert a YAML-parsed dict into a :class:`HijriDate`.

    Args:
        data: The raw dict from YAML (with ``year``/``month``/``day``/ ``precision`` keys), or ``None``.

    Returns:
        A validated :class:`HijriDate`, or None.
    """
    if data is None:
        return None
    return HijriDate(**data)


def _parse_greg(data: dict | None) -> GregorianDate | None:
    """Convert a YAML-parsed dict into a :class:`GregorianDate`.

    Args:
        data: A dict with ``date`` / ``precision`` / ``method`` keys or None.

    Returns:
        A validated :class:`GregorianDate`, or None.
    """
    if data is None:
        return None
    return GregorianDate(
        date=_parse_date_maybe(data.get("date")),
        precision=Precision(data.get("precision", "day")),
        method=data.get("method", "attested"),
    )


def _upsert_source(session: Session, data: dict) -> Source:
    """Create or return the :class:`Source` keyed by ``data['key']``.

    Args:
        session: Open session.
        data: Source record from YAML.

    Returns:
        The persisted Source.
    """
    existing = session.exec(select(Source).where(Source.key == data["key"])).first()
    if existing is not None:
        return existing
    source = Source(
        key=data["key"],
        name=data["name"],
        work_title=data.get("work_title"),
        author=data.get("author"),
        era=data.get("era"),
        url=data.get("url"),
        notes=data.get("notes"),
    )
    session.add(source)
    session.flush()
    return source


def _upsert_person(session: Session, data: dict) -> Person:
    """Create or return the :class:`Person` keyed by ``data['slug']``.

    Args:
        session: Open session.
        data: Person record from YAML.

    Returns:
        The persisted Person.
    """
    existing = session.exec(select(Person).where(Person.slug == data["slug"])).first()
    if existing is not None:
        return existing
    person = Person(
        slug=data["slug"],
        full_name_en=data["full_name_en"],
        full_name_ar=data.get("full_name_ar"),
        kunya=data.get("kunya"),
        laqab=data.get("laqab"),
        nisba=data.get("nisba"),
        biography_en=data.get("biography_en"),
        role=data.get("role"),
        wikidata_qid=data.get("wikidata_qid"),
        openiti_id=data.get("openiti_id"),
        is_sahabi=data.get("is_sahabi", False),
        is_prophet=data.get("is_prophet", False),
        is_ahl_al_bayt=data.get("is_ahl_al_bayt", False),
        image_url=data.get("image_url"),
        image_blocked_reason=data.get("image_blocked_reason"),
    )
    session.add(person)
    session.flush()
    return person


def _upsert_tag(session: Session, name: str) -> Tag:
    """Create or return the :class:`Tag` keyed by ``name``.

    Args:
        session: Open session.
        name: Tag name.

    Returns:
        The persisted Tag.
    """
    existing = session.exec(select(Tag).where(Tag.name == name)).first()
    if existing is not None:
        return existing
    tag = Tag(name=name)
    session.add(tag)
    session.flush()
    return tag


def _apply_display_keys(
    event: Event,
    hijri: HijriDate | None,
    gregorian: GregorianDate | None,
) -> None:
    """Populate the month-primary and day-anniversary indices on an event.

    Month indices (``display_*_month``) are populated whenever month-or-finer
    precision is available — these drive the daily content rotation.

    Day-anniversary indices (``display_*_doy`` / ``display_hijri_md_key``)
    are populated only when the day is genuinely attested. If we only have
    month-precision Hijri but a day-attested Gregorian (or vice versa), we
    populate just the side that's authentic — never invent precision.

    Args:
        event: The event being prepared for insertion (mutated in place).
        hijri: Optional Hijri date (for the Hijri side).
        gregorian: Optional Gregorian date (for the Gregorian side).
    """
    # --- Month indices ---
    if hijri is not None and hijri.month is not None:
        event.display_hijri_month = hijri.month
    if gregorian is not None and gregorian.date_ is not None:
        event.display_gregorian_month = gregorian.date_.month

    # --- Day-anniversary indices (only when day is genuinely attested) ---
    if gregorian is not None and gregorian.date_ and gregorian.precision == Precision.DAY:
        event.display_gregorian_doy = greg_doy(gregorian.date_)
    if hijri is not None and hijri.precision == Precision.DAY and hijri.month and hijri.day:
        event.display_hijri_md_key = hijri_md_key(hijri.month, hijri.day)


def _record_claims(
    session: Session,
    *,
    event: Event,
    raw_claims: list,
    source_map: dict[str, Source],
) -> int:
    """Insert :class:`DateClaim` rows for a curated event.

    Args:
        session: Open session.
        event: The already-persisted Event.
        raw_claims: The YAML ``claims`` list (may be empty or None).
        source_map: Lookup of source ``key`` → Source.

    Returns:
        The number of claims successfully inserted.
    """
    inserted = 0
    for claim_data in raw_claims or []:
        source_key = claim_data["source_key"]
        source = source_map.get(source_key)
        if source is None:
            console.log(f"[yellow]Unknown source_key '{source_key}' on event {event.slug}[/]")
            continue
        hijri = _parse_hijri(claim_data.get("hijri"))
        gregorian = _parse_greg(claim_data.get("gregorian"))
        session.add(
            DateClaim(
                event_id=event.id,
                source_id=source.id,
                hijri_year=hijri.year if hijri else None,
                hijri_month=hijri.month if hijri else None,
                hijri_day=hijri.day if hijri else None,
                hijri_precision=hijri.precision.value if hijri else None,
                gregorian_date=gregorian.date_ if gregorian else None,
                gregorian_precision=gregorian.precision.value if gregorian else None,
                gregorian_method=gregorian.method if gregorian else None,
                is_canonical=claim_data.get("is_canonical", False),
                notes=claim_data.get("notes"),
                source_url=claim_data.get("source_url"),
                source_quote_ar=claim_data.get("source_quote_ar"),
                source_quote_en=claim_data.get("source_quote_en"),
                verified_at=_parse_date_maybe(claim_data.get("verified_at")),
            )
        )
        inserted += 1
    return inserted


def _record_people_links(session: Session, event: Event, raw_people: list) -> None:
    """Attach people to an event by slug, with an explicit relation.

    Args:
        session: Open session.
        event: The Event being wired up.
        raw_people: YAML list of ``[slug, relation]`` pairs.
    """
    for link in raw_people or []:
        if not (isinstance(link, list) and len(link) == 2):
            continue
        person_slug, relation = link
        person = session.exec(select(Person).where(Person.slug == person_slug)).first()
        if person is None:
            console.log(f"[yellow]Unknown person '{person_slug}' on event {event.slug}[/]")
            continue
        session.add(EventPerson(event_id=event.id, person_id=person.id, relation=relation))


def _record_tags(session: Session, event: Event, raw_tags: list[str]) -> None:
    """Tag an event, creating Tag rows on demand.

    Args:
        session: Open session.
        event: The Event being tagged.
        raw_tags: Tag names from YAML.
    """
    for tag_name in raw_tags or []:
        tag = _upsert_tag(session, tag_name)
        session.add(EventTag(event_id=event.id, tag_id=tag.id))


def _upsert_event(
    session: Session,
    data: dict,
    source_map: dict[str, Source],
) -> Event | None:
    """Persist a curated event along with its claims, people, and tags.

    Args:
        session: Open session.
        data: The event record from YAML.
        source_map: Lookup of source ``key`` → Source.

    Returns:
        The persisted Event, or None if the slug already existed.
    """
    existing = session.exec(select(Event).where(Event.slug == data["slug"])).first()
    if existing is not None:
        return existing

    canonical_hijri = _parse_hijri(data.get("canonical_hijri"))
    canonical_greg = _parse_greg(data.get("canonical_gregorian"))
    if canonical_greg is None and canonical_hijri is not None:
        canonical_greg = hijri_to_gregorian(canonical_hijri)

    raw_claims = data.get("claims") or []
    # Default verification: derived from claim count unless YAML specifies it.
    default_verification = "cross_verified" if len(raw_claims) >= 2 else "single_source"

    event = Event(
        slug=data["slug"],
        category=data["category"],
        title_en=data["title_en"],
        title_ar=data.get("title_ar"),
        title_fr=data.get("title_fr"),
        description_en=data["description_en"],
        description_ar=data.get("description_ar"),
        description_fr=data.get("description_fr"),
        canonical_hijri_year=canonical_hijri.year if canonical_hijri else None,
        canonical_hijri_month=canonical_hijri.month if canonical_hijri else None,
        canonical_hijri_day=canonical_hijri.day if canonical_hijri else None,
        canonical_hijri_precision=(canonical_hijri.precision.value if canonical_hijri else None),
        canonical_gregorian_date=canonical_greg.date_ if canonical_greg else None,
        canonical_gregorian_precision=(canonical_greg.precision.value if canonical_greg else None),
        canonical_gregorian_method=canonical_greg.method if canonical_greg else None,
        julian_date=_parse_date_maybe(data.get("julian_date")),
        wikidata_qid=data.get("wikidata_qid"),
        importance=data.get("importance", "notable"),
        verification_status=data.get("verification_status", default_verification),
        verified=data.get("verified", False),
        disputed=data.get("disputed", False),
        dispute_about=data.get("dispute_about"),
        quran_refs=data.get("quran_refs"),
        hadith_refs=data.get("hadith_refs"),
        source_url=derive_source_url(
            explicit=data.get("source_url"),
            hadith_refs=data.get("hadith_refs"),
            quran_refs=data.get("quran_refs"),
            wikidata_qid=data.get("wikidata_qid"),
        ),
        image_url=data.get("image_url"),
        image_attribution=data.get("image_attribution"),
        image_license=data.get("image_license"),
    )
    _apply_display_keys(event, canonical_hijri, canonical_greg)
    session.add(event)
    session.flush()

    _record_claims(
        session,
        event=event,
        raw_claims=raw_claims,
        source_map=source_map,
    )
    _record_people_links(session, event, data.get("people") or [])
    _record_tags(session, event, data.get("tags") or [])
    return event


def _upsert_lesson(session: Session, data: dict) -> DatelessLesson:
    """Persist a dateless lesson record.

    Args:
        session: Open session.
        data: Lesson record from YAML.

    Returns:
        The persisted :class:`DatelessLesson`.
    """
    existing = session.exec(select(DatelessLesson).where(DatelessLesson.slug == data["slug"])).first()
    if existing is not None:
        return existing
    lesson = DatelessLesson(
        slug=data["slug"],
        category=data["category"],
        title_en=data["title_en"],
        title_ar=data.get("title_ar"),
        title_fr=data.get("title_fr"),
        description_en=data["description_en"],
        description_ar=data.get("description_ar"),
        description_fr=data.get("description_fr"),
        reference=data.get("reference"),
        source_notes=data.get("source_notes"),
        source_notes_ar=data.get("source_notes_ar"),
        source_notes_fr=data.get("source_notes_fr"),
        display_day_of_year=int(data["display_day_of_year"]),
        quran_refs=data.get("quran_refs"),
        hadith_refs=data.get("hadith_refs"),
        source_url=derive_source_url(
            explicit=data.get("source_url"),
            hadith_refs=data.get("hadith_refs"),
            quran_refs=data.get("quran_refs"),
        ),
        image_url=data.get("image_url"),
        image_attribution=data.get("image_attribution"),
        image_license=data.get("image_license"),
    )
    session.add(lesson)
    session.flush()
    return lesson


def _load_yaml_files(directory: Path) -> list[dict]:
    """Load every ``*.yaml`` file in a directory, returning their parsed contents.

    Files are loaded in sorted order so era-named prefixes (``01_…``,
    ``02_…``) control the ingestion order deterministically.

    Args:
        directory: Directory to search. Must exist.

    Returns:
        A list of top-level dicts, one per YAML file.
    """
    if not directory.exists():
        return []
    payloads: list[dict] = []
    for path in sorted(directory.glob("*.yaml")):
        with path.open() as handle:
            payload = yaml.safe_load(handle)
        if payload is not None:
            payloads.append(payload)
    return payloads


def _ingest_sources(session: Session, curated_dir: Path) -> dict[str, Source]:
    """Load ``sources.yaml`` and return a key → Source lookup.

    Args:
        session: Open session.
        curated_dir: Root curated directory.

    Returns:
        Dict mapping source ``key`` to the persisted Source.
    """
    source_map: dict[str, Source] = {}
    with (curated_dir / "sources.yaml").open() as handle:
        payload = yaml.safe_load(handle)
    for data in payload.get("sources", []):
        source_map[data["key"]] = _upsert_source(session, data)
    return source_map


def _ingest_people(session: Session, curated_dir: Path) -> int:
    """Load ``people.yaml`` into the database.

    Args:
        session: Open session.
        curated_dir: Root curated directory.

    Returns:
        Count of people records loaded.
    """
    with (curated_dir / "people.yaml").open() as handle:
        payload = yaml.safe_load(handle)
    count = 0
    for data in payload.get("people", []):
        _upsert_person(session, data)
        count += 1
    return count


def _ingest_events(
    session: Session,
    events_dir: Path,
    source_map: dict[str, Source],
) -> tuple[int, int]:
    """Load every ``events/*.yaml`` file.

    Args:
        session: Open session.
        events_dir: Directory containing era-split event YAMLs.
        source_map: Source key → Source lookup from :func:`_ingest_sources`.

    Returns:
        Tuple of ``(events_inserted, claims_inserted)``.
    """
    events_inserted = 0
    claims_inserted = 0
    for payload in _load_yaml_files(events_dir):
        for data in payload.get("events", []):
            event = _upsert_event(session, data, source_map)
            if event is None:
                continue
            events_inserted += 1
            claims_inserted += len(data.get("claims") or [])
    return events_inserted, claims_inserted


def _ingest_lessons(session: Session, lessons_dir: Path) -> int:
    """Load every ``lessons/*.yaml`` file. Multiple lessons may share a day.

    Args:
        session: Open session.
        lessons_dir: Directory containing dateless-lesson YAMLs.

    Returns:
        Count of lessons inserted.
    """
    inserted = 0
    for payload in _load_yaml_files(lessons_dir):
        for data in payload.get("lessons", []):
            _upsert_lesson(session, data)
            inserted += 1
    return inserted


def _upsert_observance(session: Session, data: dict) -> Observance:
    """Create or return the :class:`Observance` keyed by ``data['slug']``.

    Args:
        session: Open session.
        data: Observance record from YAML.

    Returns:
        The persisted Observance.
    """
    existing = session.exec(select(Observance).where(Observance.slug == data["slug"])).first()
    if existing is not None:
        return existing
    observance = Observance(
        slug=data["slug"],
        name_en=data["name_en"],
        name_ar=data.get("name_ar"),
        name_fr=data.get("name_fr"),
        description_en=data["description_en"],
        description_ar=data.get("description_ar"),
        description_fr=data.get("description_fr"),
        hijri_month=int(data["hijri_month"]),
        hijri_day=data.get("hijri_day"),
        window_days=int(data.get("window_days", 1)),
        quran_refs=data.get("quran_refs"),
        hadith_refs=data.get("hadith_refs"),
        importance=data.get("importance", "major"),
    )
    session.add(observance)
    session.flush()
    return observance


def _ingest_observances(session: Session, curated_dir: Path) -> int:
    """Load the optional ``observances.yaml`` file of recurring Islamic dates.

    Args:
        session: Open session.
        curated_dir: Root curated directory.

    Returns:
        Count of observances inserted.
    """
    path = curated_dir / "observances.yaml"
    if not path.exists():
        return 0
    with path.open() as handle:
        payload = yaml.safe_load(handle)
    if payload is None:
        return 0
    count = 0
    for data in payload.get("observances", []):
        _upsert_observance(session, data)
        count += 1
    return count


def ingest(session: Session, curated_dir: Path = CURATED_DIR) -> dict[str, int]:
    """Load every curated YAML file into the database.

    Args:
        session: An open SQLAlchemy session.
        curated_dir: Root of the curated data tree.

    Returns:
        Dict with counts of sources, people, events, claims, lessons, and observances.
    """
    events_dir = curated_dir / "events" if curated_dir != CURATED_DIR else CURATED_EVENTS_DIR
    lessons_dir = curated_dir / "lessons" if curated_dir != CURATED_DIR else CURATED_LESSONS_DIR

    source_map = _ingest_sources(session, curated_dir)
    people_count = _ingest_people(session, curated_dir)
    events_inserted, claims_inserted = _ingest_events(session, events_dir, source_map)
    lessons_inserted = _ingest_lessons(session, lessons_dir)
    observances_inserted = _ingest_observances(session, curated_dir)
    session.flush()

    return {
        "sources": len(source_map),
        "people": people_count,
        "events": events_inserted,
        "claims": claims_inserted,
        "lessons": lessons_inserted,
        "observances": observances_inserted,
    }
