"""Lessons route — list + single lesson lookup."""

from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query

from thaqafa.api.cache import CACHE_FIVE_MIN, CACHE_HOUR
from thaqafa.api.controllers.lessons import LessonsController
from thaqafa.api.schemas.lesson import LessonDetail, LessonListResponse
from thaqafa.dependencies import get_lessons_controller

router = APIRouter(prefix="/lessons", tags=["lessons"])


@router.get(
    "",
    response_model=LessonListResponse,
    response_model_by_alias=True,
    summary="List lessons with optional category filter",
    dependencies=[CACHE_FIVE_MIN],
)
async def list_lessons(
    controller: Annotated[LessonsController, Depends(get_lessons_controller)],
    category: Annotated[str | None, Query(max_length=48, description="Filter by lesson category.")] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 30,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> LessonListResponse:
    """Paginated lesson list."""
    return await controller.list_lessons(category=category, limit=limit, offset=offset)


@router.get(
    "/{slug}",
    response_model=LessonDetail,
    response_model_by_alias=True,
    summary="Single lesson detail by slug",
    dependencies=[CACHE_HOUR],
)
async def get_lesson(
    controller: Annotated[LessonsController, Depends(get_lessons_controller)],
    slug: Annotated[str, Path(min_length=1, max_length=160, pattern=r"^[a-z0-9][a-z0-9\-]*$")],
) -> LessonDetail:
    """Return the full lesson payload for ``slug``."""
    return await controller.get_by_slug(slug)
