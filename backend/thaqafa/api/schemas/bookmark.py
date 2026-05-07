"""Bookmark request and response schemas."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import Field

from thaqafa.api.schemas.shared import RequestModel, ResponseModel

BookmarkKind = Literal["event", "lesson", "observance", "person"]


class BookmarkCreate(RequestModel):
    """Inputs for ``POST /api/v1/bookmarks``."""

    target_kind: BookmarkKind
    target_slug: str = Field(min_length=1, max_length=160, pattern=r"^[a-z0-9][a-z0-9\-]*$")
    note: str | None = Field(default=None, max_length=512)


class BookmarkOut(ResponseModel):
    """A single bookmark — what the saves list returns."""

    id: UUID
    target_kind: BookmarkKind
    target_slug: str
    target_title: str | None
    target_title_ar: str | None
    target_title_fr: str | None
    note: str | None
    created_at: datetime


class BookmarkList(ResponseModel):
    """Paginated bookmarks payload."""

    items: list[BookmarkOut]
    total: int
