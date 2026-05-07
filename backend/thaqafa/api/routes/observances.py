"""Observances route — list + single observance lookup."""

from typing import Annotated

from fastapi import APIRouter, Depends, Path

from thaqafa.api.cache import CACHE_DAY
from thaqafa.api.controllers.observances import ObservancesController
from thaqafa.api.schemas.observance import ObservanceDetail
from thaqafa.dependencies import get_observances_controller

router = APIRouter(prefix="/observances", tags=["observances"])


@router.get(
    "",
    response_model=list[ObservanceDetail],
    response_model_by_alias=True,
    summary="List every recurring annual observance",
    dependencies=[CACHE_DAY],
)
async def list_observances(
    controller: Annotated[ObservancesController, Depends(get_observances_controller)],
) -> list[ObservanceDetail]:
    """Return every observance, ordered by Hijri month + day."""
    return await controller.list_all()


@router.get(
    "/{slug}",
    response_model=ObservanceDetail,
    response_model_by_alias=True,
    summary="Single observance by slug",
    dependencies=[CACHE_DAY],
)
async def get_observance(
    controller: Annotated[ObservancesController, Depends(get_observances_controller)],
    slug: Annotated[str, Path(min_length=1, max_length=128, pattern=r"^[a-z0-9][a-z0-9\-]*$")],
) -> ObservanceDetail:
    """Look up one observance."""
    return await controller.get_by_slug(slug)
