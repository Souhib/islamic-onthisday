"""Recent route — the last N days of Today payloads."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query

from iotd.api.cache import CACHE_UNTIL_MIDNIGHT
from iotd.api.controllers.recent import RecentController
from iotd.api.schemas.today import RecentResponse
from iotd.dependencies import get_recent_controller

router = APIRouter(prefix="/recent", tags=["recent"])


@router.get(
    "",
    response_model=RecentResponse,
    response_model_by_alias=True,
    summary="Recent days — headline and observance for the last N calendar days",
    dependencies=[CACHE_UNTIL_MIDNIGHT],
)
async def get_recent(
    controller: Annotated[RecentController, Depends(get_recent_controller)],
    days: Annotated[int, Query(ge=1, le=14, description="Number of days to look back.")] = 7,
) -> RecentResponse:
    """Return the Recent payload."""
    return await controller.recent(days)
