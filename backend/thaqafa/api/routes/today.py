"""Today route — the primary "open the app" endpoint.

The route deliberately doesn't expose a ``?on=YYYY-MM-DD`` parameter: the
"Today" experience is a daily ritual, and letting users binge through every
calendar day would dissolve that. Direct permalinks for specific events,
lessons, and observances live on ``/api/v1/events/{slug}`` etc. — those
cover the share / cite / SEO surface without breaking the daily cadence.
"""

from typing import Annotated

from fastapi import APIRouter, Depends

from thaqafa.api.cache import CACHE_UNTIL_MIDNIGHT
from thaqafa.api.controllers.today import TodayController
from thaqafa.api.schemas.today import TodayResponse
from thaqafa.dependencies import get_today_controller

router = APIRouter(prefix="/today", tags=["today"])


@router.get(
    "",
    response_model=TodayResponse,
    response_model_by_alias=True,
    summary="Headline event, secondary rails, observance for the current day",
    dependencies=[CACHE_UNTIL_MIDNIGHT],
)
async def get_today(
    controller: Annotated[TodayController, Depends(get_today_controller)],
) -> TodayResponse:
    """Return the Today payload for the current UTC day.

    A CDN can serve the same payload to thousands of readers in the same
    time zone with one origin hit; the dependency stamps a Cache-Control
    that expires at the next UTC midnight so the rollover is automatic.
    """
    return await controller.today()
