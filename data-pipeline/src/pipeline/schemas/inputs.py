"""Pydantic schemas used for ingestion input and validation."""

from datetime import date
from enum import StrEnum

from pydantic import Field, field_validator

from pipeline.schemas.shared import BaseModel


class Precision(StrEnum):
    YEAR = "year"
    MONTH = "month"
    DAY = "day"


class EventCategory(StrEnum):
    """Semantic category — drives UI filtering and iconography."""

    PROPHETIC_ERA = "prophetic_era"
    RASHIDUN = "rashidun"
    UMAYYAD = "umayyad"
    ABBASID = "abbasid"
    BATTLE = "battle"
    SCHOLAR_BIRTH = "scholar_birth"
    SCHOLAR_DEATH = "scholar_death"
    CALIPH_EVENT = "caliph_event"
    CONQUEST = "conquest"
    TREATY = "treaty"
    FOUNDING = "founding"
    REVELATION = "revelation"
    QURAN_STORY = "quran_story"
    HADITH_NARRATIVE = "hadith_narrative"
    SUNNAH_PRACTICE = "sunnah_practice"
    OTHER = "other"


class Relation(StrEnum):
    SUBJECT = "subject"
    LEADER = "leader"
    KILLED = "killed"
    BORN = "born"
    DIED = "died"
    PARTICIPANT = "participant"
    OPPOSED = "opposed"


class HijriDate(BaseModel):
    """A Hijri date with explicit precision (Wikidata-style)."""

    year: int | None = None
    month: int | None = Field(default=None, ge=1, le=12)
    day: int | None = Field(default=None, ge=1, le=30)
    precision: Precision

    @field_validator("precision")
    @classmethod
    def _consistent_precision(cls, v: Precision, info) -> Precision:
        """Validate that enough date components are present for the given precision.

        Args:
            v: The precision level being validated.
            info: Pydantic validation info with access to previously-validated data.

        Returns:
            The validated precision.

        Raises:
            ValueError: If the precision requires components that are missing.
        """
        data = info.data
        if v == Precision.DAY and (data.get("day") is None or data.get("month") is None):
            raise ValueError("day-precision requires year, month, and day")
        if v == Precision.MONTH and data.get("month") is None:
            raise ValueError("month-precision requires year and month")
        if v == Precision.YEAR and data.get("year") is None:
            raise ValueError("year-precision requires year")
        return v


class GregorianDate(BaseModel):
    date_: date | None = Field(default=None, alias="date")
    precision: Precision
    method: str = "attested"


class SourceIn(BaseModel):
    key: str
    name: str
    work_title: str | None = None
    author: str | None = None
    era: str | None = None
    url: str | None = None
    notes: str | None = None


class DateClaimIn(BaseModel):
    source_key: str
    hijri: HijriDate | None = None
    gregorian: GregorianDate | None = None
    is_canonical: bool = False
    notes: str | None = None


class PersonIn(BaseModel):
    slug: str
    full_name_en: str
    full_name_ar: str | None = None
    kunya: str | None = None
    laqab: str | None = None
    nisba: str | None = None
    biography_en: str | None = None
    role: str | None = None
    wikidata_qid: str | None = None
    openiti_id: str | None = None
    is_sahabi: bool = False
    is_prophet: bool = False
    is_ahl_al_bayt: bool = False
    image_url: str | None = None
    image_blocked_reason: str | None = None


class EventIn(BaseModel):
    slug: str
    category: EventCategory
    title_en: str
    title_ar: str | None = None
    title_fr: str | None = None
    description_en: str
    description_ar: str | None = None
    description_fr: str | None = None
    canonical_hijri: HijriDate | None = None
    canonical_gregorian: GregorianDate | None = None
    claims: list[DateClaimIn] = Field(default_factory=list)
    people: list[tuple[str, Relation]] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    wikidata_qid: str | None = None
    disputed: bool = False
    # "date" | "detail" | "interpretation" — required when disputed is true.
    dispute_about: str | None = None
    verified: bool = False
    image_url: str | None = None
    image_attribution: str | None = None
    image_license: str | None = None
