"""Events controller — single-event lookup by slug."""

from pipeline.models.db import DateClaim, Event, EventPerson
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import EventNotFoundError
from iotd.api.schemas.event import EventDetail
from iotd.api.services.projections import project_event_detail


class EventsController:
    """Looks up individual events by slug."""

    def __init__(self, session: AsyncSession):
        self.session = session

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
