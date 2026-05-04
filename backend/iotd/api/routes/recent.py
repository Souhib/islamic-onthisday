"""Recent route — the last 7 calendar days.

The window is fixed at 7 by ``RECENT_WINDOW_DAYS`` — see CLAUDE.md
rule 15. It serves a single purpose: catch-up for users who missed
a few daily readings. It is not a scrub knob.
"""

from typing import Annotated

from fastapi import APIRouter, Depends

from iotd.api.cache import CACHE_UNTIL_MIDNIGHT
from iotd.api.controllers.recent import RecentController
from iotd.api.schemas.today import RecentResponse
from iotd.dependencies import get_recent_controller

router = APIRouter(prefix="/recent", tags=["recent"])


@router.get(
    "",
    response_model=RecentResponse,
    response_model_by_alias=True,
    summary="Recent days — headline and observance for the last 7 calendar days",
    dependencies=[CACHE_UNTIL_MIDNIGHT],
)
async def get_recent(
    controller: Annotated[RecentController, Depends(get_recent_controller)],
) -> RecentResponse:
    """Return the Recent payload — the catch-up window."""
    return await controller.recent()
