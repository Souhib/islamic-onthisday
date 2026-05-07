"""Bookmarks routes — list / create / delete the authenticated user's saves."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Path, Query, status
from fastapi.responses import Response

from thaqafa.api.cache import NO_STORE
from thaqafa.api.controllers.bookmarks import BookmarksController
from thaqafa.api.schemas.bookmark import BookmarkCreate, BookmarkList, BookmarkOut
from thaqafa.dependencies import get_bookmarks_controller, get_current_user
from thaqafa.models.user import User

router = APIRouter(prefix="/bookmarks", tags=["bookmarks"])


@router.get(
    "",
    response_model=BookmarkList,
    response_model_by_alias=True,
    summary="List the authenticated user's saved items",
    dependencies=[NO_STORE],
)
async def list_bookmarks(
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[BookmarksController, Depends(get_bookmarks_controller)],
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> BookmarkList:
    return await controller.list_for_user(user.id, limit=limit, offset=offset)


@router.post(
    "",
    response_model=BookmarkOut,
    response_model_by_alias=True,
    status_code=status.HTTP_201_CREATED,
    summary="Save a new bookmark",
    dependencies=[NO_STORE],
)
async def create_bookmark(
    body: BookmarkCreate,
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[BookmarksController, Depends(get_bookmarks_controller)],
) -> BookmarkOut:
    return await controller.create(user.id, body)


@router.delete(
    "/{bookmark_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete one of the authenticated user's bookmarks",
    dependencies=[NO_STORE],
)
async def delete_bookmark(
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[BookmarksController, Depends(get_bookmarks_controller)],
    bookmark_id: Annotated[UUID, Path()],
) -> Response:
    await controller.delete(user.id, bookmark_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
