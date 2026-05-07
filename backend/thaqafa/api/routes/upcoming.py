"""Upcoming route — the next N calendar days, starting today.

Mirrors ``/recent`` but runs forward instead of backward. Mobile uses
it to pre-fetch the next several days' headlines so it can schedule
rich-content local notifications (titles baked into the alert) without
running a push-server. The dataset is curated weeks in advance, so the
headline for any future day is deterministic — same query path as
``/recent``, just with a forward-walking date list.

The window size is caller-controlled (``?days=N``, max 30) instead of
fixed at 7 like ``/recent``: the mobile schedules either 7 or up to 30
notifications at a time depending on how aggressively it wants to fill
the OS pending-notification queue.
"""

from typing import Annotated

from fastapi import APIRouter, Depends, Query

from thaqafa.api.cache import CACHE_UNTIL_MIDNIGHT
from thaqafa.api.controllers.recent import RecentController
from thaqafa.api.schemas.today import RecentResponse
from thaqafa.dependencies import get_recent_controller

router = APIRouter(prefix="/upcoming", tags=["upcoming"])

# Cap at 30 — iOS limits an app to 64 pending local notifications and we
# want headroom for repeating fallbacks; 30 covers a month of pre-fetch
# without bumping into that ceiling.
MAX_UPCOMING_DAYS = 30


@router.get(
    "",
    response_model=RecentResponse,
    response_model_by_alias=True,
    summary="Upcoming days — headline + observance for the next N calendar days",
    dependencies=[CACHE_UNTIL_MIDNIGHT],
)
async def get_upcoming(
    controller: Annotated[RecentController, Depends(get_recent_controller)],
    days: Annotated[
        int,
        Query(
            ge=1,
            le=MAX_UPCOMING_DAYS,
            description="How many days to look ahead, starting today.",
        ),
    ] = 7,
) -> RecentResponse:
    """Return the Upcoming payload — pre-fetch window for daily notifications."""
    return await controller.upcoming(days)
