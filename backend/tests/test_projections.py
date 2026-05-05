"""Unit tests for ``iotd.api.services.projections``.

Pure-function coverage — no DB, no async. Builds tiny in-memory ORM
instances and asserts the projection helpers shape them correctly.
"""

from datetime import UTC, date, datetime

from pipeline.models.db import DateClaim, DatelessLesson, Event, EventPerson, Observance, Person, Source

from iotd.api.services.projections import (
    _coerce_verification_status,
    _project_disputed_positions,
    project_event_detail,
    project_event_summary,
    project_lesson_detail,
    project_lesson_summary,
    project_observance_detail,
    project_person_detail,
    split_description,
)


def _make_event(**overrides) -> Event:
    """Build an Event with the minimum required fields for a projection."""
    base: dict = {
        "slug": "fall-of-granada",
        "category": "conquest",
        "title_en": "Fall of Granada",
        "title_ar": "سقوط غرناطة",
        "title_fr": None,
        "description_en": "After ten years of war.\n\nThe treaty was signed.",
        "canonical_hijri_year": 897,
        "canonical_hijri_month": 3,
        "canonical_hijri_day": 2,
        "canonical_gregorian_date": date(1492, 1, 2),
        "importance": "major",
        "verification_status": "cross_verified",
        "verified": True,
        "disputed": False,
        "image_url": None,
        "claims": [],
        "people_links": [],
    }
    base.update(overrides)
    return Event(**base)


def test_split_description_handles_empty_and_paragraphs() -> None:
    assert split_description(None) == ("", [])
    assert split_description("") == ("", [])
    assert split_description("only summary") == ("only summary", [])
    assert split_description("a\n\nb\n\nc") == ("a", ["b", "c"])


def test_coerce_verification_status_passes_through_known_values() -> None:
    for v in ("scholar_reviewed", "cross_verified", "single_source", "unverified"):
        assert _coerce_verification_status(v) == v


def test_coerce_verification_status_drops_legacy_auto_verified() -> None:
    """The deprecated ``auto_verified`` tier is no longer a valid API status —
    legacy ORM rows (if any ever existed) degrade to ``unverified``."""
    assert _coerce_verification_status("auto_verified") == "unverified"


def test_coerce_verification_status_falls_back_to_unverified() -> None:
    """Stray ORM values become ``unverified`` rather than break the FE union."""
    assert _coerce_verification_status(None) == "unverified"
    assert _coerce_verification_status("") == "unverified"
    assert _coerce_verification_status("legacy_string") == "unverified"
    # Even a kebab-case version (the OLD format) is rejected — snake_case only.
    assert _coerce_verification_status("cross-verified") == "unverified"


def test_project_event_summary_builds_canonical_hijri_string() -> None:
    summary = project_event_summary(_make_event())
    assert summary.id == "fall-of-granada"
    assert summary.title == "Fall of Granada"
    assert summary.title_ar == "سقوط غرناطة"
    assert summary.gregorian == "1492-01-02"
    assert summary.hijri == "2 Rabīʿ I 897 AH"
    assert summary.verification_status == "cross_verified"
    assert summary.disputed is False


def test_project_event_summary_handles_missing_dates() -> None:
    """Year-only events return a shorter Hijri string and ``None`` Gregorian."""
    summary = project_event_summary(
        _make_event(
            canonical_hijri_year=400,
            canonical_hijri_month=None,
            canonical_hijri_day=None,
            canonical_gregorian_date=None,
        ),
    )
    assert summary.hijri == "400 AH"
    assert summary.gregorian is None


def test_project_event_detail_splits_summary_and_body() -> None:
    detail = project_event_detail(_make_event())
    assert detail.summary == "After ten years of war."
    assert detail.body == ["The treaty was signed."]
    assert detail.no_image is True  # image_url is None
    assert detail.verification_status == "cross_verified"


def test_project_event_detail_drops_invalid_verification_status() -> None:
    detail = project_event_detail(_make_event(verification_status="legacy_value"))
    assert detail.verification_status == "unverified"


def test_project_disputed_positions_returns_empty_when_one_claim() -> None:
    event = _make_event()
    assert _project_disputed_positions(event) == []


def test_project_disputed_positions_orders_canonical_first() -> None:
    """When ≥2 distinct hijri triples exist, canonical wins rank 1."""
    src1 = Source(id=1, slug="ibn-kathir", name="Ibn Kathīr", era="classical")
    src2 = Source(id=2, slug="al-tabari", name="al-Ṭabarī", era="classical")
    src3 = Source(id=3, slug="al-dhahabi", name="al-Dhahabī", era="classical")

    minor = DateClaim(hijri_year=900, hijri_month=4, hijri_day=5, is_canonical=False)
    minor.source = src1
    canonical = DateClaim(hijri_year=897, hijri_month=3, hijri_day=2, is_canonical=True)
    canonical.source = src2
    other = DateClaim(hijri_year=897, hijri_month=3, hijri_day=4, is_canonical=False)
    other.source = src3

    event = _make_event(claims=[minor, canonical, other])
    positions = _project_disputed_positions(event)
    assert len(positions) == 3
    assert positions[0].rank == 1
    assert "897" in positions[0].value  # canonical
    assert positions[0].weight == "primary"
    assert positions[1].weight == "notable"
    assert positions[2].weight == "minority"


def test_project_lesson_summary_carries_kind_discriminant() -> None:
    lesson = DatelessLesson(
        slug="patience",
        category="quran_story",
        title_en="On Patience",
        description_en="Be patient.",
        display_day_of_year=42,
    )
    summary = project_lesson_summary(lesson)
    assert summary.kind == "lesson"
    assert summary.id == "patience"
    assert summary.category == "quran_story"


def test_project_lesson_detail_splits_body() -> None:
    lesson = DatelessLesson(
        slug="patience",
        category="quran_story",
        title_en="On Patience",
        description_en="Lede paragraph.\n\nBody paragraph one.\n\nBody paragraph two.",
        display_day_of_year=42,
    )
    detail = project_lesson_detail(lesson)
    assert detail.summary == "Lede paragraph."
    assert detail.body == ["Body paragraph one.", "Body paragraph two."]


def test_project_observance_detail_carries_trilingual_fields() -> None:
    obs = Observance(
        slug="day-of-arafah",
        name_en="Day of ʿArafah",
        name_ar="يوم عرفة",
        name_fr="Jour d'Arafat",
        description_en="Pilgrim's standing at Arafah.",
        description_ar="وقوف الحجاج بعرفة.",
        description_fr="La station des pèlerins à Arafat.",
        hijri_month=12,
        hijri_day=9,
        importance="major",
    )
    detail = project_observance_detail(obs)
    assert detail.name_en == "Day of ʿArafah"
    assert detail.name_ar == "يوم عرفة"
    assert detail.name_fr == "Jour d'Arafat"
    assert detail.description_en == "Pilgrim's standing at Arafah."
    assert detail.description_fr == "La station des pèlerins à Arafat."


def test_project_person_detail_blocks_image_for_prophet() -> None:
    p = Person(slug="ibrahim", full_name_en="Ibrāhīm", is_prophet=True, image_url="https://example/img.jpg")
    detail = project_person_detail(p)
    assert detail.image_url is None
    assert detail.image_blocked_reason == "prophet"


def test_project_person_detail_blocks_image_for_sahabi_and_ahl_al_bayt() -> None:
    sahabi = Person(slug="abu-bakr", full_name_en="Abū Bakr", is_sahabi=True, image_url="x")
    ahl = Person(slug="fatima", full_name_en="Fāṭimah", is_ahl_al_bayt=True, image_url="x")
    assert project_person_detail(sahabi).image_blocked_reason == "sahabi"
    assert project_person_detail(ahl).image_blocked_reason == "ahl-al-bayt"


def test_project_person_detail_keeps_image_for_unrestricted_figure() -> None:
    p = Person(slug="ibn-battuta", full_name_en="Ibn Baṭṭūṭa", image_url="https://example/ib.jpg")
    detail = project_person_detail(p)
    assert detail.image_url == "https://example/ib.jpg"
    assert detail.image_blocked_reason is None


# ---------------------------------------------------------------------------
# project_event_detail people / sources clipping
# ---------------------------------------------------------------------------


def _make_event_with_links(n_people: int, n_claims: int) -> Event:
    src = Source(id=1, slug="src", name="Source", era="classical")
    claims = []
    for i in range(n_claims):
        c = DateClaim(hijri_year=897, hijri_month=3, hijri_day=i + 1)
        c.source = src
        c.source_url = f"https://example/{i}"
        claims.append(c)
    people_links = []
    for i in range(n_people):
        person = Person(slug=f"p{i}", full_name_en=f"Person {i}")
        link = EventPerson(relation="subject")
        link.person = person
        people_links.append(link)
    return _make_event(claims=claims, people_links=people_links)


def test_project_event_detail_clips_people_and_sources_to_limit() -> None:
    """``EVENT_PEOPLE_LIMIT`` and ``EVENT_SOURCES_LIMIT`` are 12 — confirm clipping."""
    detail = project_event_detail(_make_event_with_links(n_people=20, n_claims=20))
    assert len(detail.people) == 12
    assert len(detail.sources) == 12


def test_project_event_detail_handles_naive_orm_relations() -> None:
    """``project_event_detail`` is called with synthetic instances above; check
    we don't depend on SQLAlchemy session attachment.
    """
    detail = project_event_detail(_make_event())
    # Today's helpers don't touch session-bound attributes — they just read
    # plain Python fields. This test guards against accidental future
    # ``session.refresh`` calls inside the projection.
    assert detail.id == "fall-of-granada"


def test_project_event_detail_uses_canonical_hijri_string_helper() -> None:
    """The hijri string format ("2 Rabīʿ I 897 AH") is shared with summaries."""
    detail = project_event_detail(_make_event())
    summary = project_event_summary(_make_event())
    assert detail.hijri == summary.hijri


# Datetime helper used elsewhere
def _utc(year: int, month: int, day: int) -> datetime:
    return datetime(year, month, day, tzinfo=UTC)
