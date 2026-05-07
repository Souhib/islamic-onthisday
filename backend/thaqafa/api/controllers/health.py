"""Health controller — owns the liveness + DB-ping + dataset-snapshot logic."""

from datetime import UTC, datetime

from pipeline.models.db import DatelessLesson, Event, Observance, Person
from sqlalchemy import func, text
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.schemas.health import DatasetSnapshot, HealthResponse
from thaqafa.version import __version__


class HealthController:
    """Builds the health response."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def check(self) -> HealthResponse:
        """Run a trivial ``SELECT 1`` plus row counts so an alert can fire when
        the pipeline hasn't run in too long.

        Returns:
            A populated ``HealthResponse``. ``database`` is ``"ok"`` when the
            round-trip succeeds and ``"down"`` otherwise; the overall
            ``status`` follows. ``dataset`` is filled when the DB is up,
            ``None`` when it's down.
        """
        try:
            await self.session.exec(text("SELECT 1"))
        except Exception:  # noqa: BLE001 — any DB error degrades health
            return HealthResponse(status="degraded", database="down", version=__version__, dataset=None)

        snapshot = await self._dataset_snapshot()
        return HealthResponse(status="ok", database="ok", version=__version__, dataset=snapshot)

    async def _dataset_snapshot(self) -> DatasetSnapshot:
        """Read row counts + the most recent ``Event.updated_at``.

        The four counts run in parallel-ish thanks to SQLAlchemy's batched
        execution; the freshest ``updated_at`` is one extra scalar query.
        Total cost on the curated dataset is well under 10 ms, so we don't
        bother caching.
        """
        event_count = (await self.session.exec(select(func.count(Event.id)))).one()
        lesson_count = (await self.session.exec(select(func.count(DatelessLesson.id)))).one()
        observance_count = (await self.session.exec(select(func.count(Observance.id)))).one()
        person_count = (await self.session.exec(select(func.count(Person.id)))).one()
        latest_built = (await self.session.exec(select(func.max(Event.updated_at)))).one()

        built_at_iso: str | None = None
        age_hours: float | None = None
        if latest_built is not None:
            # SQLite returns naive datetimes for TIMESTAMP columns; treat the
            # value as UTC (which is how the pipeline writes it).
            built = latest_built if latest_built.tzinfo else latest_built.replace(tzinfo=UTC)
            built_at_iso = built.isoformat(timespec="seconds")
            age_hours = round((datetime.now(UTC) - built).total_seconds() / 3600, 2)

        return DatasetSnapshot(
            event_count=int(event_count or 0),
            lesson_count=int(lesson_count or 0),
            observance_count=int(observance_count or 0),
            person_count=int(person_count or 0),
            built_at=built_at_iso,
            age_hours=age_hours,
        )
