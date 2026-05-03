"""People controller — single-person lookup by slug.

Image policy is enforced at the data layer (the pipeline nullifies
``image_url`` for any prophet, Sahabi, or member of Ahl al-Bayt). The
projection helper re-asserts it as defense-in-depth.
"""

from pipeline.models.db import Person
from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import PersonNotFoundError
from iotd.api.schemas.person import PersonDetail
from iotd.api.services.projections import project_person_detail


class PeopleController:
    """Looks up individual people by slug."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_slug(self, slug: str) -> PersonDetail:
        """Fetch one person by slug.

        Raises:
            PersonNotFoundError: when no person matches.
        """
        stmt = select(Person).where(Person.slug == slug)
        result = await self.session.exec(stmt)
        row = result.first()
        if row is None:
            raise PersonNotFoundError(slug)
        return project_person_detail(row[0])
