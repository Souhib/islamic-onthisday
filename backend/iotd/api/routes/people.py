"""People route — single-person lookup."""

from typing import Annotated

from fastapi import APIRouter, Depends, Path

from iotd.api.cache import CACHE_HOUR
from iotd.api.controllers.people import PeopleController
from iotd.api.schemas.person import PersonDetail
from iotd.dependencies import get_people_controller

router = APIRouter(prefix="/people", tags=["people"])


@router.get(
    "/{slug}",
    response_model=PersonDetail,
    response_model_by_alias=True,
    summary="Single-person detail by slug",
    dependencies=[CACHE_HOUR],
)
async def get_person(
    controller: Annotated[PeopleController, Depends(get_people_controller)],
    slug: Annotated[str, Path(min_length=1, max_length=128, pattern=r"^[a-z0-9][a-z0-9\-]*$")],
) -> PersonDetail:
    """Return the full person payload for ``slug``."""
    return await controller.get_by_slug(slug)
