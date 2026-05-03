"""SQLModel ORM tables for the Islamic On-This-Day pipeline.

Tables inherit from :class:`pipeline.schemas.shared.BaseTable` (which carries
``created_at`` / ``updated_at`` timestamps) or :class:`BaseModel` for tables
that don't need audit timestamps. Schema maps 1:1 to PostgreSQL when the
FastAPI backend is swapped in.
"""

from datetime import date

from sqlalchemy import Column, ForeignKey, Text, UniqueConstraint
from sqlmodel import Field, Relationship

from pipeline.schemas.shared import BaseModel, BaseTable


class Source(BaseModel, table=True):
    """A citable source (Wikidata, OpenITI, al-Tabari's Tarikh, etc.)."""

    __tablename__ = "sources"

    id: int | None = Field(default=None, primary_key=True)
    key: str = Field(max_length=64, unique=True, index=True)
    name: str = Field(max_length=255)
    work_title: str | None = Field(default=None, max_length=255)
    author: str | None = Field(default=None, max_length=255)
    era: str | None = Field(default=None, max_length=64)
    url: str | None = Field(default=None, max_length=512)
    notes: str | None = Field(default=None, sa_column=Column(Text))

    claims: list["DateClaim"] = Relationship(back_populates="source")


class Person(BaseModel, table=True):
    """A historical Islamic figure. Images may be blocked for religious reasons."""

    __tablename__ = "people"

    id: int | None = Field(default=None, primary_key=True)
    slug: str = Field(max_length=128, unique=True, index=True)
    full_name_en: str = Field(max_length=255)
    full_name_ar: str | None = Field(default=None, max_length=255)
    kunya: str | None = Field(default=None, max_length=128)
    laqab: str | None = Field(default=None, max_length=128)
    nisba: str | None = Field(default=None, max_length=128)
    biography_en: str | None = Field(default=None, sa_column=Column(Text))
    role: str | None = Field(default=None, max_length=64)
    wikidata_qid: str | None = Field(default=None, max_length=32, index=True)
    openiti_id: str | None = Field(default=None, max_length=128, index=True)
    is_sahabi: bool = Field(default=False)
    is_prophet: bool = Field(default=False)
    is_ahl_al_bayt: bool = Field(default=False)
    # Image of the person (ONLY if not a prophet/sahabi/ahl al-bayt).
    image_url: str | None = Field(default=None, max_length=512)
    image_blocked_reason: str | None = Field(default=None, max_length=128)

    event_links: list["EventPerson"] = Relationship(back_populates="person")


class Event(BaseTable, table=True):
    """The canonical event record. Date claims live on :class:`DateClaim`."""

    __tablename__ = "events"

    id: int | None = Field(default=None, primary_key=True)
    slug: str = Field(max_length=160, unique=True, index=True)
    category: str = Field(max_length=48, index=True)
    title_en: str = Field(max_length=255)
    title_ar: str | None = Field(default=None, max_length=255)
    title_fr: str | None = Field(default=None, max_length=255)
    description_en: str = Field(sa_column=Column(Text, nullable=False))
    description_ar: str | None = Field(default=None, sa_column=Column(Text))
    description_fr: str | None = Field(default=None, sa_column=Column(Text))

    canonical_hijri_year: int | None = Field(default=None, index=True)
    canonical_hijri_month: int | None = Field(default=None, index=True)
    canonical_hijri_day: int | None = Field(default=None, index=True)
    canonical_hijri_precision: str | None = Field(default=None, max_length=8)

    canonical_gregorian_date: date | None = Field(default=None, index=True)
    canonical_gregorian_precision: str | None = Field(default=None, max_length=8)
    canonical_gregorian_method: str | None = Field(default=None, max_length=32)

    # MONTH-PRIMARY indices — every event with month-or-finer precision
    # gets these. The app rotates daily content from the current month's pool.
    display_hijri_month: int | None = Field(default=None, index=True)
    display_gregorian_month: int | None = Field(default=None, index=True)

    # DAY-anniversary indices — populated only when the day is genuinely
    # attested (not auto-converted from month-precision). The app uses these
    # to surface "today is the exact anniversary" callouts.
    display_gregorian_doy: int | None = Field(default=None, index=True)
    display_hijri_md_key: int | None = Field(default=None, index=True)

    # Julian-calendar equivalent for events before 15 Oct 1582. Stored
    # alongside ``canonical_gregorian_date`` (which is proleptic Gregorian)
    # so the app can show users the date they'd recognise from history books.
    julian_date: date | None = Field(default=None)

    wikidata_qid: str | None = Field(default=None, max_length=32, index=True)

    # Editorial ranking — "major" surfaces on the headline slot, "notable" on
    # secondary rails, "minor" (default for auto-imports) only on overflow.
    importance: str = Field(default="notable", max_length=12, index=True)

    # Editorial review state. Backfilled by `verification.py`:
    #   unverified      — auto-import (Wikidata, OpenITI), no human review.
    #   single_source   — one classical citation; no cross-check.
    #   cross_verified  — two or more independent classical sources confirm.
    #   scholar_reviewed — a qualified Muslim scholar has signed off.
    verification_status: str = Field(default="unverified", max_length=24, index=True)

    verified: bool = Field(default=False)
    disputed: bool = Field(default=False)
    # When ``disputed`` is true, what aspect is contested:
    #   "date"           — the canonical date is one of several attested
    #                      positions (the event itself is well-attested).
    #                      This is the dominant case (~95%).
    #   "detail"         — a small detail of the event is contested
    #                      (e.g. number of casualties, size of a party).
    #   "interpretation" — a status / qualification is contested
    #                      (e.g. whether al-Hallaj was a heretic or a martyr).
    # Required when ``disputed`` is true. The frontend uses this to calibrate
    # how prominently it surfaces the dispute.
    dispute_about: str | None = Field(default=None, max_length=24)

    # Comma-separated structured references.
    # quran_refs: e.g. "2:255, 3:97"     hadith_refs: e.g. "Bukhari 3, Muslim 8"
    quran_refs: str | None = Field(default=None, max_length=255)
    hadith_refs: str | None = Field(default=None, max_length=255)

    # Primary user-facing "verify this" URL — auto-derived from hadith_refs /
    # quran_refs if absent, otherwise the explicit value (Wikipedia, IslamQA,
    # academic article, etc.). The mobile app surfaces this as a single tap.
    source_url: str | None = Field(default=None, max_length=512)

    image_url: str | None = Field(default=None, max_length=512)
    image_attribution: str | None = Field(default=None, max_length=512)
    image_license: str | None = Field(default=None, max_length=64)

    claims: list["DateClaim"] = Relationship(
        back_populates="event",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )
    people_links: list["EventPerson"] = Relationship(
        back_populates="event",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )
    tag_links: list["EventTag"] = Relationship(
        back_populates="event",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )


class DateClaim(BaseModel, table=True):
    """A single source's attestation of an event date. Multiple per event = dispute."""

    __tablename__ = "date_claims"

    id: int | None = Field(default=None, primary_key=True)
    event_id: int = Field(
        sa_column=Column(ForeignKey("events.id", ondelete="CASCADE"), nullable=False),
    )
    source_id: int = Field(foreign_key="sources.id")

    hijri_year: int | None = Field(default=None)
    hijri_month: int | None = Field(default=None)
    hijri_day: int | None = Field(default=None)
    hijri_precision: str | None = Field(default=None, max_length=8)

    gregorian_date: date | None = Field(default=None)
    gregorian_precision: str | None = Field(default=None, max_length=8)
    gregorian_method: str | None = Field(default=None, max_length=32)

    is_canonical: bool = Field(default=False)
    notes: str | None = Field(default=None, sa_column=Column(Text))

    # User-clickable provenance — direct URL to where the user can verify the
    # claim (sunnah.com hadith page, quran.com ayah, dorar.net biography,
    # academic article, etc.).
    source_url: str | None = Field(default=None, max_length=512)
    # Direct passage from the cited source — Arabic original and translation.
    # Lets the app surface "this is exactly what al-Tabari wrote" on tap.
    source_quote_ar: str | None = Field(default=None, sa_column=Column(Text))
    source_quote_en: str | None = Field(default=None, sa_column=Column(Text))
    # When the source URL / quote was last verified by a human or agent.
    verified_at: date | None = Field(default=None)

    event: Event = Relationship(back_populates="claims")
    source: Source = Relationship(back_populates="claims")


class EventPerson(BaseModel, table=True):
    """Join table between an :class:`Event` and a :class:`Person` with an explicit relation."""

    __tablename__ = "event_people"
    __table_args__ = (UniqueConstraint("event_id", "person_id", "relation"),)

    id: int | None = Field(default=None, primary_key=True)
    event_id: int = Field(
        sa_column=Column(ForeignKey("events.id", ondelete="CASCADE"), nullable=False),
    )
    person_id: int = Field(
        sa_column=Column(ForeignKey("people.id", ondelete="CASCADE"), nullable=False),
    )
    relation: str = Field(max_length=32)

    event: Event = Relationship(back_populates="people_links")
    person: Person = Relationship(back_populates="event_links")


class Tag(BaseModel, table=True):
    """A free-form tag applied to events."""

    __tablename__ = "tags"

    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(max_length=64, unique=True, index=True)

    event_links: list["EventTag"] = Relationship(back_populates="tag")


class EventTag(BaseModel, table=True):
    """Join table between an :class:`Event` and a :class:`Tag`."""

    __tablename__ = "event_tags"
    __table_args__ = (UniqueConstraint("event_id", "tag_id"),)

    id: int | None = Field(default=None, primary_key=True)
    event_id: int = Field(
        sa_column=Column(ForeignKey("events.id", ondelete="CASCADE"), nullable=False),
    )
    tag_id: int = Field(
        sa_column=Column(ForeignKey("tags.id", ondelete="CASCADE"), nullable=False),
    )

    event: Event = Relationship(back_populates="tag_links")
    tag: Tag = Relationship(back_populates="event_links")


class DatelessLesson(BaseModel, table=True):
    """Quran/Sunnah content without a specific date — rotates by day-of-year."""

    __tablename__ = "dateless_lessons"

    id: int | None = Field(default=None, primary_key=True)
    slug: str = Field(max_length=160, unique=True, index=True)
    category: str = Field(max_length=48, index=True)
    title_en: str = Field(max_length=255)
    title_ar: str | None = Field(default=None, max_length=255)
    title_fr: str | None = Field(default=None, max_length=255)
    description_en: str = Field(sa_column=Column(Text, nullable=False))
    description_ar: str | None = Field(default=None, sa_column=Column(Text))
    description_fr: str | None = Field(default=None, sa_column=Column(Text))
    reference: str | None = Field(default=None, max_length=255)
    source_notes: str | None = Field(default=None, sa_column=Column(Text))
    source_notes_ar: str | None = Field(default=None, sa_column=Column(Text))
    source_notes_fr: str | None = Field(default=None, sa_column=Column(Text))
    # Multiple lessons may share a display_day_of_year; the backend selects one
    # per (day, year) via a deterministic rotation rather than strict 1:1.
    display_day_of_year: int = Field(index=True)
    quran_refs: str | None = Field(default=None, max_length=255)
    hadith_refs: str | None = Field(default=None, max_length=255)
    source_url: str | None = Field(default=None, max_length=512)
    image_url: str | None = Field(default=None, max_length=512)
    image_attribution: str | None = Field(default=None, max_length=512)
    image_license: str | None = Field(default=None, max_length=64)


class Observance(BaseModel, table=True):
    """A recurring annual Islamic observance keyed by Hijri month-day.

    Distinct from :class:`Event` (one-time historical occurrence). Examples:
    Eid al-Fitr (1 Shawwal), Day of Arafah (9 Dhu al-Hijja), Mawlid
    (12 Rabi al-Awwal), Laylat al-Qadr window (last 10 of Ramadan).
    """

    __tablename__ = "observances"

    id: int | None = Field(default=None, primary_key=True)
    slug: str = Field(max_length=128, unique=True, index=True)
    name_en: str = Field(max_length=128)
    name_ar: str | None = Field(default=None, max_length=128)
    name_fr: str | None = Field(default=None, max_length=128)
    description_en: str = Field(sa_column=Column(Text, nullable=False))
    description_ar: str | None = Field(default=None, sa_column=Column(Text))
    description_fr: str | None = Field(default=None, sa_column=Column(Text))
    hijri_month: int = Field(index=True)
    # Day within the Hijri month, or NULL for multi-day windows (e.g. last 10 of Ramadan).
    hijri_day: int | None = Field(default=None, index=True)
    # Optional window size in days, for observances that span several days.
    window_days: int = Field(default=1)
    quran_refs: str | None = Field(default=None, max_length=255)
    hadith_refs: str | None = Field(default=None, max_length=255)
    importance: str = Field(default="major", max_length=12)


class Image(BaseModel, table=True):
    """Blob / URL cache for downloaded images with attribution."""

    __tablename__ = "images"

    id: int | None = Field(default=None, primary_key=True)
    source_url: str = Field(max_length=512, unique=True)
    local_path: str | None = Field(default=None, max_length=512)
    license: str | None = Field(default=None, max_length=64)
    attribution: str | None = Field(default=None, max_length=512)
    depicts: str | None = Field(default=None, max_length=255)
    is_person_depiction: bool = Field(default=False)
