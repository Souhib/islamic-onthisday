"""Events route — single-event lookup by slug.

The corpus is exposed only through:
- ``/api/v1/today`` (rotation),
- ``/api/v1/recent`` (7-day catch-up),
- ``/api/v1/events/{slug}`` (permalink — for SEO inbound traffic and
  shareable references).

There is no list endpoint by design — see CLAUDE.md rule 15. The
daily-ritual model relies on the rotation surface, not on a browsable
archive; topic-axis navigation belongs to encyclopedias and is out of
scope for this product.
"""

from typing import Annotated

from fastapi import APIRouter, Depends, Path

from thaqafa.api.cache import CACHE_HOUR
from thaqafa.api.controllers.events import EventsController
from thaqafa.api.schemas.event import EventDetail
from thaqafa.dependencies import get_events_controller

router = APIRouter(prefix="/events", tags=["events"])


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
