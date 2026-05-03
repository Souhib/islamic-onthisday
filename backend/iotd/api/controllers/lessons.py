"""Lessons controller — list / search and single-lesson lookup.

Dateless lessons rotate by day-of-year and provide Qur'an / Sunnah / Hadith
content when no curated event matches a calendar day.
"""

from pipeline.models.db import DatelessLesson
from sqlalchemy import func, select
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import LessonNotFoundError
from iotd.api.schemas.lesson import LessonDetail, LessonListResponse
from iotd.api.services.projections import project_lesson_detail, project_lesson_summary


class LessonsController:
    """Looks up individual lessons by slug, plus paginated list / search."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_lessons(
        self,
        *,
        category: str | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> LessonListResponse:
        """Return a paginated lesson list filtered by category."""
        limit = max(1, min(100, limit))
        offset = max(0, offset)

        where_clauses: list = []
        if category:
            where_clauses.append(DatelessLesson.category == category)

        count_stmt = select(func.count(DatelessLesson.id))
        for clause in where_clauses:
            count_stmt = count_stmt.where(clause)
        total_result = await self.session.exec(count_stmt)
        total = int(total_result.one()[0] or 0)

        stmt = select(DatelessLesson)
        for clause in where_clauses:
            stmt = stmt.where(clause)
        stmt = (
            stmt.order_by(DatelessLesson.display_day_of_year.asc(), DatelessLesson.slug.asc())
            .limit(limit)
            .offset(offset)
        )
        rows_result = await self.session.exec(stmt)
        rows = [row[0] for row in rows_result.all()]

        return LessonListResponse(
            items=[project_lesson_summary(r) for r in rows],
            total=total,
            limit=limit,
            offset=offset,
        )

    async def get_by_slug(self, slug: str) -> LessonDetail:
        """Fetch one lesson by its slug.

        Raises:
            LessonNotFoundError: when no lesson matches the slug.
        """
        stmt = select(DatelessLesson).where(DatelessLesson.slug == slug)
        result = await self.session.exec(stmt)
        row = result.first()
        if row is None:
            raise LessonNotFoundError(slug)
        return project_lesson_detail(row[0])
