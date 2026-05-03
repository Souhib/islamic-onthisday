"""Health route — liveness + DB connectivity probe."""

from typing import Annotated

from fastapi import APIRouter, Depends

from iotd.api.cache import NO_STORE
from iotd.api.controllers.health import HealthController
from iotd.api.schemas.health import HealthResponse
from iotd.dependencies import get_health_controller

router = APIRouter(tags=["system"])


@router.get(
    "/health",
    response_model=HealthResponse,
    response_model_by_alias=True,
    summary="Liveness + DB ping",
    # Health *must* be fresh — caching it would mask a real outage.
    dependencies=[NO_STORE],
)
async def health(
    controller: Annotated[HealthController, Depends(get_health_controller)],
) -> HealthResponse:
    """Return the API health snapshot."""
    return await controller.check()
