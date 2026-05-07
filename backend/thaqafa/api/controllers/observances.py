"""Observances controller — recurring annual rites lookup."""

from pipeline.models.db import Observance
from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.errors import ObservanceNotFoundError
from thaqafa.api.schemas.observance import ObservanceDetail
from thaqafa.api.services.projections import project_observance_detail


class ObservancesController:
    """List + lookup for recurring annual observances."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_all(self) -> list[ObservanceDetail]:
        """Return every observance, ordered by Hijri month + day."""
        stmt = select(Observance).order_by(Observance.hijri_month.asc(), Observance.hijri_day.asc().nulls_last())
        result = await self.session.exec(stmt)
        rows = [row[0] for row in result.all()]
        return [project_observance_detail(o) for o in rows]

    async def get_by_slug(self, slug: str) -> ObservanceDetail:
        """Look up one observance by slug.

        Raises:
            ObservanceNotFoundError: when no observance matches.
        """
        stmt = select(Observance).where(Observance.slug == slug)
        result = await self.session.exec(stmt)
        row = result.first()
        if row is None:
            raise ObservanceNotFoundError(slug)
        return project_observance_detail(row[0])
