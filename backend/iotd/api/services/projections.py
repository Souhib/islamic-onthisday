"""Pure ORM → Pydantic projection helpers.

Single home for the row-to-payload projections used by every controller.
Splitting these out of ``controllers/today.py`` removed the
controller-to-controller import (``EventsController`` was importing private
helpers from ``TodayController``) and the parallel copies in
``controllers/lessons.py``.

These helpers must stay pure: no DB calls, no I/O. They take a single ORM
row (or a small list of them) and return the matching response model.
"""

from typing import get_args

from pipeline.models.db import DateClaim, DatelessLesson, Event, Observance, Person

from iotd.api.constants import EVENT_PEOPLE_LIMIT, EVENT_SOURCES_LIMIT, HIJRI_MONTH_NAMES_SHORT
from iotd.api.schemas.event import (
    DisputedPosition,
    EventDetail,
    EventSummary,
    PersonRef,
    SourceRef,
    VerificationStatus,
)
from iotd.api.schemas.lesson import LessonDetail, LessonSummary
from iotd.api.schemas.observance import ObservanceDetail
from iotd.api.schemas.person import PersonDetail

_VERIFICATION_STATUS_VALUES: frozenset[str] = frozenset(get_args(VerificationStatus))


def _coerce_verification_status(value: str | None) -> VerificationStatus:
    """Narrow a free-form ORM string to the API's verification ladder.

    The pipeline column is ``str`` for forward-compat; the API contract is a
    closed enum. If the YAML ever contains a value outside the union (typo,
    new tier added before the schema is widened), we degrade to
    ``unverified`` rather than emit a payload that breaks the front-end's
    type narrowing.
    """
    if value in _VERIFICATION_STATUS_VALUES:
        return value  # type: ignore[return-value]
    return "unverified"


def split_description(description: str | None) -> tuple[str, list[str]]:
    """Split a YAML description into ``(summary, body[])``.

    First paragraph becomes the lede; subsequent ``\\n\\n``-separated
    paragraphs become the body. Empty input returns ``("", [])``.
    """
    if not description:
        return "", []
    paragraphs = [p.strip() for p in description.split("\n\n") if p.strip()]
    if not paragraphs:
        return description.strip(), []
    return paragraphs[0], paragraphs[1:]


def _format_hijri(year: int | None, month: int | None, day: int | None) -> str | None:
    """Return a canonical Hijri date string (``"3 Ramaḍān 1447 AH"``).

    Returns ``None`` when no part is attested. The front-end may render this
    string verbatim or rebuild from the structured fields on the row.
    """
    parts: list[str] = []
    if day:
        parts.append(str(day))
    if month and 1 <= month <= 12:
        parts.append(HIJRI_MONTH_NAMES_SHORT[month - 1])
    if year:
        parts.append(f"{year} AH")
    return " ".join(parts) if parts else None


def project_event_summary(event: Event) -> EventSummary:
    """Project an :class:`Event` row to the slim ``EventSummary`` schema."""
    hijri = _format_hijri(event.canonical_hijri_year, event.canonical_hijri_month, event.canonical_hijri_day)
    gregorian = event.canonical_gregorian_date.isoformat() if event.canonical_gregorian_date else None
    return EventSummary(
        id=event.slug,
        title=event.title_en,
        title_ar=event.title_ar,
        title_fr=event.title_fr,
        hijri=hijri,
        gregorian=gregorian,
        era=event.category,
        importance=event.importance,
        verification_status=_coerce_verification_status(event.verification_status),
        disputed=event.disputed,
        dispute_about=event.dispute_about,  # type: ignore[arg-type]
    )


def project_event_detail(event: Event) -> EventDetail:
    """Project an :class:`Event` row to the rich ``EventDetail`` schema.

    People and sources are clipped to the configured limits. The disputed
    positions list is empty unless ``len(set(claim_dates)) >= 2``.
    """
    people = [
        PersonRef(
            id=link.person.slug,
            name=link.person.full_name_en,
            name_ar=link.person.full_name_ar,
            # Person ORM has no full_name_fr today — frontend falls back to
            # English (via pickLocalised). Keep the field on the schema so
            # the contract stays trilingual.
            name_fr=None,
            role=link.relation,
        )
        for link in (event.people_links or [])[:EVENT_PEOPLE_LIMIT]
        if link.person is not None
    ]
    sources = [
        SourceRef(label=claim.source.name, kind=_source_kind(claim.source.era), verify=claim.source_url)
        for claim in (event.claims or [])[:EVENT_SOURCES_LIMIT]
        if claim.source is not None
    ]
    summary_en, body_en = split_description(event.description_en)
    summary_ar, body_ar = split_description(event.description_ar)
    summary_fr, body_fr = split_description(event.description_fr)
    disputed_positions = _project_disputed_positions(event)
    hijri = _format_hijri(event.canonical_hijri_year, event.canonical_hijri_month, event.canonical_hijri_day)
    return EventDetail(
        id=event.slug,
        title=event.title_en,
        title_ar=event.title_ar,
        title_fr=event.title_fr,
        era=event.category,
        importance=event.importance,
        verification_status=_coerce_verification_status(event.verification_status),
        gregorian=event.canonical_gregorian_date.isoformat() if event.canonical_gregorian_date else None,
        hijri=hijri,
        location=None,
        placeholder=None,
        no_image=event.image_url is None,
        image_url=event.image_url,
        summary=summary_en,
        summary_ar=summary_ar,
        summary_fr=summary_fr,
        body=body_en,
        body_ar=body_ar,
        body_fr=body_fr,
        people=people,
        sources=sources,
        disputed=event.disputed or len(disputed_positions) > 1,
        dispute_about=event.dispute_about,  # type: ignore[arg-type]
        disputed_positions=disputed_positions,
        source_url=event.source_url,
        quran_refs=event.quran_refs,
    )


def project_lesson_summary(lesson: DatelessLesson) -> LessonSummary:
    """Project a :class:`DatelessLesson` row to ``LessonSummary``."""
    return LessonSummary(
        kind="lesson",
        id=lesson.slug,
        title=lesson.title_en,
        title_ar=lesson.title_ar,
        title_fr=lesson.title_fr,
        category=lesson.category,
        reference=lesson.reference,
    )


def project_lesson_detail(lesson: DatelessLesson) -> LessonDetail:
    """Project a :class:`DatelessLesson` row to ``LessonDetail``."""
    summary_en, body_en = split_description(lesson.description_en)
    summary_ar, body_ar = split_description(lesson.description_ar)
    summary_fr, body_fr = split_description(lesson.description_fr)
    return LessonDetail(
        kind="lesson",
        id=lesson.slug,
        title=lesson.title_en,
        title_ar=lesson.title_ar,
        title_fr=lesson.title_fr,
        category=lesson.category,
        reference=lesson.reference,
        summary=summary_en,
        summary_ar=summary_ar,
        summary_fr=summary_fr,
        body=body_en,
        body_ar=body_ar,
        body_fr=body_fr,
        quran_refs=lesson.quran_refs,
        hadith_refs=lesson.hadith_refs,
        source_url=lesson.source_url,
        source_notes=lesson.source_notes,
        source_notes_ar=lesson.source_notes_ar,
        source_notes_fr=lesson.source_notes_fr,
    )


def project_observance_detail(obs: Observance) -> ObservanceDetail:
    """Project an :class:`Observance` row to the full ``ObservanceDetail``."""
    return ObservanceDetail(
        id=obs.slug,
        name_en=obs.name_en,
        name_ar=obs.name_ar,
        name_fr=obs.name_fr,
        description_en=obs.description_en,
        description_ar=obs.description_ar,
        description_fr=obs.description_fr,
        hijri_month=obs.hijri_month,
        hijri_day=obs.hijri_day,
        window_days=obs.window_days,
        importance=obs.importance,
        quran_refs=obs.quran_refs,
        hadith_refs=obs.hadith_refs,
    )


def project_person_detail(person: Person) -> PersonDetail:
    """Project a :class:`Person` row to ``PersonDetail`` with image policy enforced."""
    image_blocked: str | None = None
    if person.is_prophet:
        image_blocked = "prophet"
    elif person.is_sahabi:
        image_blocked = "sahabi"
    elif person.is_ahl_al_bayt:
        image_blocked = "ahl-al-bayt"
    return PersonDetail(
        id=person.slug,
        full_name_en=person.full_name_en,
        full_name_ar=person.full_name_ar,
        kunya=person.kunya,
        laqab=person.laqab,
        nisba=person.nisba,
        role=person.role,
        biography=person.biography_en,
        is_prophet=person.is_prophet,
        is_sahabi=person.is_sahabi,
        is_ahl_al_bayt=person.is_ahl_al_bayt,
        image_url=None if image_blocked else person.image_url,
        image_blocked_reason=image_blocked,
        wikidata_qid=person.wikidata_qid,
    )


def _project_disputed_positions(event: Event) -> list[DisputedPosition]:
    """Build the ranked list of attested date positions on a disputed event.

    Only emitted when ≥2 distinct ``(year, month, day)`` triples exist in the
    event's claims. The canonical claim is always rank 1; remaining positions
    follow in the order they appear on the event row. ``weight`` is a
    machine-readable discriminant — the front-end maps it to a localised
    label (``"primary" → "Most widely held"`` etc.).
    """
    claims = list(event.claims or [])
    seen: dict[tuple[int | None, int | None, int | None], DateClaim] = {}
    for claim in claims:
        key = (claim.hijri_year, claim.hijri_month, claim.hijri_day)
        if key not in seen:
            seen[key] = claim
    if len(seen) < 2:
        return []

    ordered: list[DateClaim] = []
    for claim in seen.values():
        if claim.is_canonical:
            ordered.append(claim)
            break
    for claim in seen.values():
        if claim not in ordered:
            ordered.append(claim)

    weights: list[str] = ["primary", "notable", "minority"]
    positions: list[DisputedPosition] = []
    for i, claim in enumerate(ordered):
        positions.append(
            DisputedPosition(
                rank=i + 1,
                value=_format_hijri(claim.hijri_year, claim.hijri_month, claim.hijri_day) or "",
                scholars=claim.source.name if claim.source is not None else "Unattributed",
                weight=weights[i] if i < len(weights) else "minority",  # type: ignore[arg-type]
            )
        )
    return positions


def _source_kind(era: str | None) -> str:
    if era in ("classical", "primary", "modern"):
        return era
    return "modern"
