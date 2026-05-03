"""Events controller — single-event lookup + list / search."""

from pipeline.models.db import DateClaim, Event, EventPerson
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import EventNotFoundError
from iotd.api.schemas.event import EventDetail
from iotd.api.schemas.list import EventListResponse
from iotd.api.services.projections import project_event_detail, project_event_summary


class EventsController:
    """Looks up individual events by slug, plus paginated list / search."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_events(
        self,
        *,
        era: str | None = None,
        category: str | None = None,
        hijri_month: int | None = None,
        importance: str | None = None,
        q: str | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> EventListResponse:
        """Return a paginated event list filtered by the supplied criteria."""
        limit = max(1, min(100, limit))
        offset = max(0, offset)

        where_clauses: list = []
        if era and category and era != category:
            where_clauses.append(or_(Event.category == era, Event.category == category))
        elif era:
            where_clauses.append(Event.category == era)
        elif category:
            where_clauses.append(Event.category == category)
        if hijri_month is not None:
            where_clauses.append(Event.display_hijri_month == hijri_month)
        if importance:
            where_clauses.append(Event.importance == importance)
        if q:
            like = f"%{q.lower()}%"
            where_clauses.append(
                or_(func.lower(Event.title_en).like(like), func.lower(Event.description_en).like(like))
            )

        count_stmt = select(func.count(Event.id))
        for clause in where_clauses:
            count_stmt = count_stmt.where(clause)
        total_result = await self.session.exec(count_stmt)
        total = int(total_result.one()[0] or 0)

        stmt = select(Event)
        for clause in where_clauses:
            stmt = stmt.where(clause)
        stmt = (
            stmt.order_by(
                Event.verified.desc(),
                Event.importance.asc(),
                Event.canonical_gregorian_date.desc(),
            )
            .limit(limit)
            .offset(offset)
        )
        rows_result = await self.session.exec(stmt)
        rows = [row[0] for row in rows_result.all()]

        return EventListResponse(
            items=[project_event_summary(r) for r in rows],
            total=total,
            limit=limit,
            offset=offset,
        )

    async def get_by_slug(self, slug: str) -> EventDetail:
        """Fetch one event by its slug, fully hydrated for the detail view.

        Raises:
            EventNotFoundError: when no event matches the slug.
        """
        stmt = (
            select(Event)
            .where(Event.slug == slug)
            .options(
                selectinload(Event.claims).selectinload(DateClaim.source),
                selectinload(Event.people_links).selectinload(EventPerson.person),
            )
        )
        result = await self.session.exec(stmt)
        row = result.first()
        if row is None:
            raise EventNotFoundError(slug)
        return project_event_detail(row[0])
