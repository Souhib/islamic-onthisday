"""Events route — list / search + single-event lookup."""

from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query

from iotd.api.cache import CACHE_FIVE_MIN, CACHE_HOUR
from iotd.api.controllers.events import EventsController
from iotd.api.schemas.event import EventDetail
from iotd.api.schemas.list import EventListResponse
from iotd.dependencies import get_events_controller

router = APIRouter(prefix="/events", tags=["events"])


@router.get(
    "",
    response_model=EventListResponse,
    response_model_by_alias=True,
    summary="List events with optional era / month / category / text filters",
    dependencies=[CACHE_FIVE_MIN],
)
async def list_events(
    controller: Annotated[EventsController, Depends(get_events_controller)],
    era: Annotated[str | None, Query(max_length=48, description="Filter by historical era / category.")] = None,
    category: Annotated[str | None, Query(max_length=48, description="Alias for era. Joined with OR.")] = None,
    hijri_month: Annotated[int | None, Query(ge=1, le=12, description="1–12 Hijri month index.")] = None,
    importance: Annotated[
        str | None,
        Query(pattern=r"^(major|notable|minor)$", description="Importance tier filter."),
    ] = None,
    q: Annotated[
        str | None,
        Query(min_length=2, max_length=80, description="Substring match on title / description (case-insensitive)."),
    ] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 30,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> EventListResponse:
    """Paginated event list."""
    return await controller.list_events(
        era=era,
        category=category,
        hijri_month=hijri_month,
        importance=importance,
        q=q,
        limit=limit,
        offset=offset,
    )


@router.get(
    "/{slug}",
    response_model=EventDetail,
    response_model_by_alias=True,
    summary="Single-event detail by slug",
    dependencies=[CACHE_HOUR],
)
async def get_event(
    controller: Annotated[EventsController, Depends(get_events_controller)],
    slug: Annotated[str, Path(min_length=1, max_length=160, pattern=r"^[a-z0-9][a-z0-9\-]*$")],
) -> EventDetail:
    """Return the full event payload for ``slug``."""
    return await controller.get_by_slug(slug)
