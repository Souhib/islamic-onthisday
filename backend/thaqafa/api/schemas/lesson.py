"""Pydantic response shapes for the Lesson resource.

Lessons are dateless Qur'an / Sunnah / Hadith content that rotates by
day-of-year. They carry a discriminant ``kind: "lesson"`` so the frontend
can distinguish them from events in union types.
"""

from typing import Literal

from thaqafa.api.schemas.shared import ResponseModel


class LessonSummary(ResponseModel):
    """Slim lesson projection for rotation rails — trilingual."""

    kind: Literal["lesson"] = "lesson"
    id: str
    title: str
    title_ar: str | None = None
    title_fr: str | None = None
    category: str
    reference: str | None = None


class LessonDetail(ResponseModel):
    """Full lesson projection used by the headline + lesson-detail surfaces.

    Trilingual: ``title`` (English) + ``title_ar`` (Arabic) + ``title_fr``
    (French) all surfaced; ``summary`` and ``body`` likewise. Front-end
    chooses which to render.
    """

    kind: Literal["lesson"] = "lesson"
    id: str
    title: str
    title_ar: str | None = None
    title_fr: str | None = None
    category: str
    reference: str | None = None
    summary: str
    summary_ar: str | None = None
    summary_fr: str | None = None
    body: list[str] = []
    body_ar: list[str] = []
    body_fr: list[str] = []
    quran_refs: str | None = None
    hadith_refs: str | None = None
    source_url: str | None = None
    source_notes: str | None = None
    source_notes_ar: str | None = None
    source_notes_fr: str | None = None


class LessonListResponse(ResponseModel):
    """Paginated list of lessons."""

    items: list[LessonSummary] = []
    total: int
    limit: int
    offset: int
