"""FastAPI dependency providers — controllers are fully wired here.

Routers must never instantiate controllers directly; they receive pre-built
instances via ``Depends``.
"""

from typing import Annotated

from fastapi import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.controllers.events import EventsController
from iotd.api.controllers.health import HealthController
from iotd.api.controllers.lessons import LessonsController
from iotd.api.controllers.observances import ObservancesController
from iotd.api.controllers.people import PeopleController
from iotd.api.controllers.recent import RecentController
from iotd.api.controllers.today import TodayController
from iotd.database import get_session


async def get_today_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> TodayController:
    """Return a ``TodayController`` wired to the request session."""
    return TodayController(session)


async def get_recent_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> RecentController:
    """Return a ``RecentController`` wired to the request session.

    The recent payload no longer composes ``TodayController.today`` per-day
    (that pattern was N+1 — see ``RecentController._pick_headlines``).
    """
    return RecentController(session)


async def get_events_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> EventsController:
    """Return an ``EventsController`` wired to the request session."""
    return EventsController(session)


async def get_lessons_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> LessonsController:
    """Return a ``LessonsController`` wired to the request session."""
    return LessonsController(session)


async def get_observances_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> ObservancesController:
    """Return an ``ObservancesController`` wired to the request session."""
    return ObservancesController(session)


async def get_people_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> PeopleController:
    """Return a ``PeopleController`` wired to the request session."""
    return PeopleController(session)


async def get_health_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> HealthController:
    """Return a ``HealthController`` wired to the request session."""
    return HealthController(session)
