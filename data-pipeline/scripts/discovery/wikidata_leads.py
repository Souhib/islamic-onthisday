"""Wikidata SPARQL ingestion.

Pulls two datasets:

1. Persons of the Islamic world with :wikidata:`P570` (date of death),
   at any precision the knowledge graph records.
2. Battles attached to Islamic-world conflicts, with :wikidata:`P585`
   (point in time).

Only day- and month-precision dates become Tier-1/Tier-2 events in the
output database. Year-precision entries are stored as Tier-3 and appear
under "this Hijri year" tiles.
"""

from datetime import date

from rich.console import Console
from slugify import slugify
from SPARQLWrapper import JSON, SPARQLWrapper
from sqlmodel import Session, select

from pipeline.constants import (
    WIKIDATA_HISTORICAL_CUTOFF_YEAR,
    WIKIDATA_PRECISION_DAY,
    WIKIDATA_PRECISION_MONTH,
    WIKIDATA_SPARQL_ENDPOINT,
    WIKIDATA_USER_AGENT,
)
from pipeline.conversion.calendar import greg_md_key, gregorian_to_hijri, hijri_md_key
from pipeline.models.db import DateClaim, Event, Person, Source
from pipeline.schemas.inputs import EventCategory
from pipeline.source_urls import wikidata_url

console = Console()

PERSONS_QUERY: str = f"""
SELECT ?item ?itemLabel ?dob ?dobPrecision ?dod ?dodPrecision ?image WHERE {{
  ?item wdt:P140 wd:Q432 .
  ?item p:P570 ?dodStmt .
  ?dodStmt psv:P570 ?dodNode .
  ?dodNode wikibase:timeValue ?dod .
  ?dodNode wikibase:timePrecision ?dodPrecision .
  OPTIONAL {{
    ?item p:P569 ?dobStmt .
    ?dobStmt psv:P569 ?dobNode .
    ?dobNode wikibase:timeValue ?dob .
    ?dobNode wikibase:timePrecision ?dobPrecision .
  }}
  OPTIONAL {{ ?item wdt:P18 ?image . }}
  FILTER (YEAR(?dod) <= {WIKIDATA_HISTORICAL_CUTOFF_YEAR}) .
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
}}
LIMIT 5000
"""

BATTLES_QUERY: str = f"""
SELECT DISTINCT ?item ?itemLabel ?pit ?pitPrecision ?image WHERE {{
  ?item wdt:P31/wdt:P279* wd:Q178561 .
  {{
    ?item wdt:P361 ?war . ?war wdt:P31/wdt:P279* wd:Q831663 .
    ?war (wdt:P710|wdt:P1344|wdt:P607) ?muslim_party .
    FILTER EXISTS {{ ?muslim_party wdt:P140 wd:Q432 . }}
  }} UNION {{
    ?item (wdt:P710|wdt:P1344|wdt:P607) ?p .
    ?p wdt:P140 wd:Q432 .
  }} UNION {{
    ?item wdt:P361 ?w .
    VALUES ?w {{
      wd:Q9289086 wd:Q1184715 wd:Q229488 wd:Q192944 wd:Q12193
    }}
  }}
  ?item p:P585 ?stmt .
  ?stmt psv:P585 ?node .
  ?node wikibase:timeValue ?pit .
  ?node wikibase:timePrecision ?pitPrecision .
  OPTIONAL {{ ?item wdt:P18 ?image . }}
  FILTER (YEAR(?pit) <= {WIKIDATA_HISTORICAL_CUTOFF_YEAR}) .
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
}}
LIMIT 2000
"""

# Mosques + masjids of the Islamic world with attested foundation dates AND
# an English Wikipedia article (the schema:isPartOf clause guarantees the
# entry has a real article — anything without one would never survive
# pipeline.verify anyway, so we pre-filter at the SPARQL level).
MOSQUES_QUERY: str = f"""
SELECT DISTINCT ?item ?itemLabel ?inception ?inceptionPrecision ?image WHERE {{
  ?item wdt:P31/wdt:P279* wd:Q32815 .
  ?item p:P571 ?stmt .
  ?stmt psv:P571 ?node .
  ?node wikibase:timeValue ?inception .
  ?node wikibase:timePrecision ?inceptionPrecision .
  ?article schema:about ?item ;
           schema:isPartOf <https://en.wikipedia.org/> .
  OPTIONAL {{ ?item wdt:P18 ?image . }}
  FILTER (YEAR(?inception) <= {WIKIDATA_HISTORICAL_CUTOFF_YEAR}) .
  FILTER (YEAR(?inception) > 0) .
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
}}
LIMIT 800
"""

# Sieges in Muslim-world conflicts (separate from battles in Wikidata's
# ontology — Q188055). Pre-filter on enwiki sitelink.
SIEGES_QUERY: str = f"""
SELECT DISTINCT ?item ?itemLabel ?pit ?pitPrecision ?image WHERE {{
  ?item wdt:P31/wdt:P279* wd:Q188055 .
  {{
    ?item (wdt:P710|wdt:P1344|wdt:P607) ?p .
    ?p wdt:P140 wd:Q432 .
  }} UNION {{
    ?item wdt:P361 ?war . ?war wdt:P31/wdt:P279* wd:Q831663 .
    ?war (wdt:P710|wdt:P1344|wdt:P607) ?muslim_party .
    FILTER EXISTS {{ ?muslim_party wdt:P140 wd:Q432 . }}
  }}
  ?item p:P585 ?stmt .
  ?stmt psv:P585 ?node .
  ?node wikibase:timeValue ?pit .
  ?node wikibase:timePrecision ?pitPrecision .
  ?article schema:about ?item ;
           schema:isPartOf <https://en.wikipedia.org/> .
  OPTIONAL {{ ?item wdt:P18 ?image . }}
  FILTER (YEAR(?pit) <= {WIKIDATA_HISTORICAL_CUTOFF_YEAR}) .
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
}}
LIMIT 500
"""

# Treaties / peace agreements involving Muslim-world parties + enwiki.
TREATIES_QUERY: str = f"""
SELECT DISTINCT ?item ?itemLabel ?pit ?pitPrecision ?image WHERE {{
  ?item wdt:P31/wdt:P279* wd:Q625298 .
  ?item (wdt:P710|wdt:P1344|wdt:P607|wdt:P1449|wdt:P50) ?p .
  ?p wdt:P140 wd:Q432 .
  ?item p:P585 ?stmt .
  ?stmt psv:P585 ?node .
  ?node wikibase:timeValue ?pit .
  ?node wikibase:timePrecision ?pitPrecision .
  ?article schema:about ?item ;
           schema:isPartOf <https://en.wikipedia.org/> .
  OPTIONAL {{ ?item wdt:P18 ?image . }}
  FILTER (YEAR(?pit) <= {WIKIDATA_HISTORICAL_CUTOFF_YEAR}) .
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
}}
LIMIT 300
"""


def _run_sparql(query: str) -> list[dict]:
    """Execute a SPARQL query against the Wikidata endpoint.

    Args:
        query: A SPARQL query string.

    Returns:
        The ``bindings`` list from the JSON response. Empty on error.
    """
    client = SPARQLWrapper(WIKIDATA_SPARQL_ENDPOINT, agent=WIKIDATA_USER_AGENT)
    client.setQuery(query)
    client.setReturnFormat(JSON)
    return client.query().convert()["results"]["bindings"]


def _precision_from_int(raw: str | int) -> str:
    """Map Wikidata's ``timePrecision`` integer to our string enum.

    Args:
        raw: The precision value from Wikidata (9=year, 10=month, 11=day).

    Returns:
        One of ``"day"``, ``"month"``, ``"year"``.
    """
    value = int(raw)
    if value >= WIKIDATA_PRECISION_DAY:
        return "day"
    if value == WIKIDATA_PRECISION_MONTH:
        return "month"
    return "year"


def _parse_date_literal(value: str) -> date | None:
    """Parse an ISO-ish Wikidata date literal into a Python :class:`date`.

    Wikidata encodes dates as strings like ``+0870-09-01T00:00:00Z``. BCE
    dates (prefixed with ``-``) and invalid strings return ``None``.

    Args:
        value: The raw Wikidata date literal.

    Returns:
        A Python :class:`date`, or None if the value is unparseable or BCE.
    """
    if not value:
        return None
    trimmed = value.lstrip("+")
    if trimmed.startswith("-"):
        return None
    try:
        return date.fromisoformat(trimmed.split("T")[0])
    except ValueError:
        return None


def _get_wikidata_source(session: Session) -> Source:
    """Fetch or create the canonical Wikidata :class:`Source` row.

    Args:
        session: An open SQLAlchemy session.

    Returns:
        The persisted Source record keyed by "wikidata".
    """
    existing = session.exec(select(Source).where(Source.key == "wikidata")).first()
    if existing is not None:
        return existing
    src = Source(
        key="wikidata",
        name="Wikidata",
        url="https://www.wikidata.org/",
        era="tertiary",
        notes="Structured data graph.",
    )
    session.add(src)
    session.flush()
    return src


def _insert_person_death_event(
    session: Session,
    *,
    source: Source,
    qid: str,
    label: str,
    slug_base: str,
    death_date: date,
    precision: str,
    image: str | None,
) -> bool:
    """Create a ``scholar_death`` Event for a Wikidata person.

    Args:
        session: Open session.
        source: Cached Wikidata source record.
        qid: Wikidata Q-ID of the subject.
        label: Localized label for the subject.
        slug_base: Slugified subject name for slug construction.
        death_date: Attested Gregorian death date.
        precision: One of ``"day"``, ``"month"``, ``"year"``.
        image: Optional image URL from Wikidata P18.

    Returns:
        True if the event was inserted, False if it already existed.
    """
    event_slug = f"wd-death-{slug_base}-{qid.lower()}"[:160]
    if session.exec(select(Event).where(Event.slug == event_slug)).first() is not None:
        return False

    hy, hm, hd = gregorian_to_hijri(death_date)
    day_precise = precision == "day"
    event = Event(
        slug=event_slug,
        category=EventCategory.SCHOLAR_DEATH.value,
        title_en=f"Death of {label}",
        description_en=(
            f"Death of {label}, attested in Wikidata (QID {qid}). "
            f"Date precision: {precision}. "
            f"This record is imported from the Wikidata knowledge graph and "
            f"has not yet been manually cross-checked against classical sources."
        ),
        canonical_gregorian_date=death_date if day_precise else None,
        canonical_gregorian_precision=precision,
        canonical_gregorian_method="attested",
        canonical_hijri_year=hy if day_precise else None,
        canonical_hijri_month=hm if day_precise else None,
        canonical_hijri_day=hd if day_precise else None,
        canonical_hijri_precision=precision if day_precise else None,
        display_gregorian_month=death_date.month,
        display_hijri_month=hm,
        display_gregorian_md_key=greg_md_key(death_date) if day_precise else None,
        display_hijri_md_key=hijri_md_key(hm, hd) if day_precise else None,
        wikidata_qid=qid,
        source_url=wikidata_url(qid),
        importance="minor",
        verification_status="unverified",
        verified=False,
        image_url=image,
    )
    session.add(event)
    session.flush()
    session.add(
        DateClaim(
            event_id=event.id,
            source_id=source.id,
            gregorian_date=death_date if day_precise else None,
            gregorian_precision=precision,
            gregorian_method="attested",
            is_canonical=True,
        )
    )
    return True


def _insert_battle_event(
    session: Session,
    *,
    source: Source,
    qid: str,
    label: str,
    slug_base: str,
    point_date: date,
    precision: str,
    image: str | None,
) -> bool:
    """Create a ``battle`` Event for a Wikidata battle record.

    Returns:
        True if inserted, False if already present.
    """
    event_slug = f"wd-battle-{slug_base}-{qid.lower()}"[:160]
    if session.exec(select(Event).where(Event.slug == event_slug)).first() is not None:
        return False

    hy, hm, hd = gregorian_to_hijri(point_date)
    day_precise = precision == "day"
    event = Event(
        slug=event_slug,
        category=EventCategory.BATTLE.value,
        title_en=label,
        description_en=(
            f"{label} — battle record imported from Wikidata (QID {qid}). "
            f"Date precision: {precision}. Not yet manually cross-checked."
        ),
        canonical_gregorian_date=point_date if day_precise else None,
        canonical_gregorian_precision=precision,
        canonical_gregorian_method="attested",
        canonical_hijri_year=hy if day_precise else None,
        canonical_hijri_month=hm if day_precise else None,
        canonical_hijri_day=hd if day_precise else None,
        canonical_hijri_precision=precision if day_precise else None,
        display_gregorian_month=point_date.month,
        display_hijri_month=hm,
        display_gregorian_md_key=greg_md_key(point_date) if day_precise else None,
        display_hijri_md_key=hijri_md_key(hm, hd) if day_precise else None,
        wikidata_qid=qid,
        source_url=wikidata_url(qid),
        importance="notable",
        verification_status="unverified",
        verified=False,
        image_url=image,
    )
    session.add(event)
    session.flush()
    session.add(
        DateClaim(
            event_id=event.id,
            source_id=source.id,
            gregorian_date=point_date if day_precise else None,
            gregorian_precision=precision,
            gregorian_method="attested",
            is_canonical=True,
        )
    )
    return True


def _insert_dated_event(
    session: Session,
    *,
    source: Source,
    qid: str,
    label: str,
    slug_base: str,
    point_date: date,
    precision: str,
    image: str | None,
    category: EventCategory,
    slug_prefix: str,
    description_subject: str,
) -> bool:
    """Create a dated Event for any Wikidata item with an inception/event date.

    Generic helper used by the mosques / sieges / treaties / etc. ingestors.

    Args:
        session: Open SQLModel session.
        source: Cached Wikidata source row.
        qid: Wikidata Q-identifier.
        label: Wikidata enwiki label (used as title_en).
        slug_base: Slugified label.
        point_date: The Gregorian inception/event date.
        precision: ``"day" | "month" | "year"``.
        image: Optional image URL.
        category: ``EventCategory`` to assign.
        slug_prefix: Short token for the slug (e.g. ``"mosque"``, ``"siege"``).
        description_subject: Short subject phrase used in the auto description
            (e.g. ``"foundation of the mosque"``, ``"siege"``).

    Returns:
        True when inserted, False when the slug already exists.
    """
    event_slug = f"wd-{slug_prefix}-{slug_base}-{qid.lower()}"[:160]
    if session.exec(select(Event).where(Event.slug == event_slug)).first() is not None:
        return False

    hy, hm, hd = gregorian_to_hijri(point_date)
    day_precise = precision == "day"
    event = Event(
        slug=event_slug,
        category=category.value,
        title_en=label,
        description_en=(
            f"{label} — {description_subject} record imported from Wikidata "
            f"(QID {qid}). Date precision: {precision}. "
            "Not yet manually cross-checked against classical sources."
        ),
        canonical_gregorian_date=point_date if day_precise else None,
        canonical_gregorian_precision=precision,
        canonical_gregorian_method="attested",
        canonical_hijri_year=hy if day_precise else None,
        canonical_hijri_month=hm if day_precise else None,
        canonical_hijri_day=hd if day_precise else None,
        canonical_hijri_precision=precision if day_precise else None,
        display_gregorian_month=point_date.month,
        display_hijri_month=hm,
        display_gregorian_md_key=greg_md_key(point_date) if day_precise else None,
        display_hijri_md_key=hijri_md_key(hm, hd) if day_precise else None,
        wikidata_qid=qid,
        source_url=wikidata_url(qid),
        importance="notable",
        verification_status="unverified",
        verified=False,
        image_url=image,
    )
    session.add(event)
    session.flush()
    session.add(
        DateClaim(
            event_id=event.id,
            source_id=source.id,
            gregorian_date=point_date if day_precise else None,
            gregorian_precision=precision,
            gregorian_method="attested",
            is_canonical=True,
        )
    )
    return True


def _safe_run(label: str, query: str) -> list[dict]:
    """Run a SPARQL query and swallow/log any failure so ingestion continues.

    Args:
        label: Short description of the query for log output.
        query: SPARQL query body.

    Returns:
        Bindings list or ``[]`` on error.
    """
    console.log(f"[cyan]Querying Wikidata: {label}…[/]")
    try:
        rows = _run_sparql(query)
    except Exception as exc:  # noqa: BLE001 — defensive: don't kill ingestion
        console.log(f"[red]Wikidata {label} query failed: {exc}[/]")
        return []
    console.log(f"  got {len(rows)} rows")
    return rows


def _ingest_person_row(
    session: Session,
    *,
    source: Source,
    row: dict,
    existing_qids: set[str],
    processed: set[str],
    counts: dict[str, int],
) -> None:
    """Handle a single person-row from the Wikidata death-date query.

    Args:
        session: Open SQLAlchemy session.
        source: Cached Wikidata source row.
        row: A single SPARQL binding.
        existing_qids: QIDs already persisted from curated data.
        processed: QIDs already processed in this ingest (mutated).
        counts: Accumulator dict (mutated).
    """
    qid = row["item"]["value"].rsplit("/", 1)[-1]
    if qid in existing_qids:
        counts["persons_skipped_curated"] += 1
        return
    if qid in processed:
        return
    processed.add(qid)

    label = row.get("itemLabel", {}).get("value") or qid
    dod_precision = _precision_from_int(row["dodPrecision"]["value"])
    death_date = _parse_date_literal(row["dod"]["value"])
    if death_date is None:
        return

    slug_base = slugify(label) or qid.lower()
    person_slug = f"wd-{slug_base}-{qid.lower()}"[:128]
    image = row.get("image", {}).get("value")

    person = Person(
        slug=person_slug,
        full_name_en=label,
        wikidata_qid=qid,
        is_sahabi=False,
        is_prophet=False,
        is_ahl_al_bayt=False,
        image_url=image,
    )
    session.add(person)
    session.flush()
    counts["persons_added"] += 1

    if dod_precision not in ("day", "month"):
        return
    inserted = _insert_person_death_event(
        session,
        source=source,
        qid=qid,
        label=label,
        slug_base=slug_base,
        death_date=death_date,
        precision=dod_precision,
        image=image,
    )
    if inserted:
        counts["events_added"] += 1


def _ingest_battle_row(
    session: Session,
    *,
    source: Source,
    row: dict,
    existing_event_qids: set[str],
    processed: set[str],
    counts: dict[str, int],
) -> None:
    """Handle a single battle-row from the Wikidata battles query.

    Args:
        session: Open SQLAlchemy session.
        source: Cached Wikidata source row.
        row: A single SPARQL binding.
        existing_event_qids: Battle QIDs already persisted.
        processed: Battle QIDs already processed in this ingest (mutated).
        counts: Accumulator dict (mutated).
    """
    qid = row["item"]["value"].rsplit("/", 1)[-1]
    if qid in existing_event_qids or qid in processed:
        return
    processed.add(qid)

    label = row.get("itemLabel", {}).get("value") or qid
    precision = _precision_from_int(row["pitPrecision"]["value"])
    point_date = _parse_date_literal(row["pit"]["value"])
    if point_date is None:
        return

    slug_base = slugify(label) or qid.lower()
    image = row.get("image", {}).get("value")
    inserted = _insert_battle_event(
        session,
        source=source,
        qid=qid,
        label=label,
        slug_base=slug_base,
        point_date=point_date,
        precision=precision,
        image=image,
    )
    if inserted:
        counts["events_added"] += 1


def _ingest_dated_event_row(
    session: Session,
    *,
    source: Source,
    row: dict,
    existing_event_qids: set[str],
    processed: set[str],
    counts: dict[str, int],
    date_var: str,
    precision_var: str,
    category: EventCategory,
    slug_prefix: str,
    description_subject: str,
) -> None:
    """Generic row handler for any "item with a single date" SPARQL result.

    Used by the mosques (inception date), sieges (point in time), and
    treaties (point in time) ingestors.

    Args:
        session: Open SQLModel session.
        source: Cached Wikidata source row.
        row: A single SPARQL binding.
        existing_event_qids: QIDs already persisted as events.
        processed: QIDs handled in this ingest pass (mutated).
        counts: Accumulator dict (mutated).
        date_var: Name of the SPARQL variable carrying the date
            (``"inception"`` or ``"pit"``).
        precision_var: Matching precision variable.
        category: ``EventCategory`` to assign.
        slug_prefix: Short token for the slug.
        description_subject: Short subject phrase for auto descriptions.
    """
    qid = row["item"]["value"].rsplit("/", 1)[-1]
    if qid in existing_event_qids or qid in processed:
        return
    processed.add(qid)

    label = row.get("itemLabel", {}).get("value") or qid
    precision = _precision_from_int(row[precision_var]["value"])
    point_date = _parse_date_literal(row[date_var]["value"])
    if point_date is None:
        return

    slug_base = slugify(label) or qid.lower()
    image = row.get("image", {}).get("value")
    inserted = _insert_dated_event(
        session,
        source=source,
        qid=qid,
        label=label,
        slug_base=slug_base,
        point_date=point_date,
        precision=precision,
        image=image,
        category=category,
        slug_prefix=slug_prefix,
        description_subject=description_subject,
    )
    if inserted:
        counts["events_added"] += 1


def ingest(session: Session) -> dict[str, int]:
    """Run all Wikidata queries and persist their results.

    Args:
        session: An open SQLAlchemy session.

    Returns:
        Dict with counts of persons added, events added, and persons skipped
        because they were already present from a curated source.
    """
    counts: dict[str, int] = {"persons_added": 0, "events_added": 0, "persons_skipped_curated": 0}
    source = _get_wikidata_source(session)

    # 1. Muslim persons with death dates
    person_rows = _safe_run("Muslim persons with death dates", PERSONS_QUERY)
    existing_qids: set[str] = set(
        session.exec(select(Person.wikidata_qid).where(Person.wikidata_qid.isnot(None))).all()
    )
    processed_person_qids: set[str] = set()
    for row in person_rows:
        _ingest_person_row(
            session,
            source=source,
            row=row,
            existing_qids=existing_qids,
            processed=processed_person_qids,
            counts=counts,
        )

    # 2. Battles
    battle_rows = _safe_run("Islamic-world battles", BATTLES_QUERY)
    existing_event_qids: set[str] = set(
        session.exec(select(Event.wikidata_qid).where(Event.wikidata_qid.isnot(None))).all()
    )
    processed_event_qids: set[str] = set()
    for row in battle_rows:
        _ingest_battle_row(
            session,
            source=source,
            row=row,
            existing_event_qids=existing_event_qids,
            processed=processed_event_qids,
            counts=counts,
        )

    # 3. Mosques (foundation dates) — pre-filtered on enwiki sitelink, so
    #    every entry survives pipeline.verify after auto-promotion.
    mosque_rows = _safe_run("Historical mosques (with enwiki)", MOSQUES_QUERY)
    for row in mosque_rows:
        _ingest_dated_event_row(
            session,
            source=source,
            row=row,
            existing_event_qids=existing_event_qids,
            processed=processed_event_qids,
            counts=counts,
            date_var="inception",
            precision_var="inceptionPrecision",
            category=EventCategory.FOUNDING,
            slug_prefix="mosque",
            description_subject="historic mosque foundation",
        )

    # 4. Sieges in Muslim-world conflicts (separate from "battle" in
    #    Wikidata's ontology) — also pre-filtered on enwiki.
    siege_rows = _safe_run("Sieges in Muslim-world conflicts (enwiki)", SIEGES_QUERY)
    for row in siege_rows:
        _ingest_dated_event_row(
            session,
            source=source,
            row=row,
            existing_event_qids=existing_event_qids,
            processed=processed_event_qids,
            counts=counts,
            date_var="pit",
            precision_var="pitPrecision",
            category=EventCategory.BATTLE,
            slug_prefix="siege",
            description_subject="siege",
        )

    # 5. Treaties involving Muslim-world parties + enwiki.
    treaty_rows = _safe_run("Treaties involving Muslim parties (enwiki)", TREATIES_QUERY)
    for row in treaty_rows:
        _ingest_dated_event_row(
            session,
            source=source,
            row=row,
            existing_event_qids=existing_event_qids,
            processed=processed_event_qids,
            counts=counts,
            date_var="pit",
            precision_var="pitPrecision",
            category=EventCategory.TREATY,
            slug_prefix="treaty",
            description_subject="treaty",
        )

    session.flush()
    return counts
