"""Bookmarks controller — list / create / delete a user's saved items.

The catalogue is keyed by ``(target_kind, target_slug)`` so we don't need
hard FK relationships to the content tables (which the pipeline rebuilds
from scratch). Slug existence is verified at create time, and the list
view joins back to fetch titles in the user's preferred language.
"""

from uuid import UUID

from pipeline.models.db import DatelessLesson, Event, Observance, Person
from sqlalchemy import delete, func, select
from sqlalchemy.exc import IntegrityError
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.errors import BookmarkNotFoundError, BookmarkTargetNotFoundError
from thaqafa.api.schemas.bookmark import BookmarkCreate, BookmarkList, BookmarkOut
from thaqafa.models.user import Bookmark, BookmarkTargetKind

_TARGET_TABLE = {
    BookmarkTargetKind.EVENT: Event,
    BookmarkTargetKind.LESSON: DatelessLesson,
    BookmarkTargetKind.OBSERVANCE: Observance,
    BookmarkTargetKind.PERSON: Person,
}


class BookmarksController:
    """Looks up and mutates the bookmarks belonging to one user."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_for_user(self, user_id: UUID, *, limit: int = 100, offset: int = 0) -> BookmarkList:
        """Return the user's bookmarks, newest first, with target titles attached."""
        count_stmt = select(func.count()).select_from(Bookmark).where(Bookmark.user_id == user_id)
        count_row = (await self.session.exec(count_stmt)).one()
        total = int(count_row[0]) if hasattr(count_row, "__getitem__") else int(count_row)

        stmt = (
            select(Bookmark)
            .where(Bookmark.user_id == user_id)
            .order_by(Bookmark.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        rows = (await self.session.exec(stmt)).all()
        bookmarks: list[Bookmark] = [r[0] for r in rows]

        items: list[BookmarkOut] = []
        for bm in bookmarks:
            titles = await self._resolve_titles(bm.target_kind, bm.target_slug)
            items.append(
                BookmarkOut(
                    id=bm.id,
                    target_kind=bm.target_kind,  # type: ignore[arg-type]
                    target_slug=bm.target_slug,
                    target_title=titles[0],
                    target_title_ar=titles[1],
                    target_title_fr=titles[2],
                    note=bm.note,
                    created_at=bm.created_at,
                )
            )
        return BookmarkList(items=items, total=total)

    async def create(self, user_id: UUID, body: BookmarkCreate) -> BookmarkOut:
        """Save one resource. Idempotent for the same ``(kind, slug)`` pair."""
        # Validate the target actually exists in the catalogue. Without this,
        # a typoed slug would land in the user's saves and 404 forever.
        kind = BookmarkTargetKind(body.target_kind)
        await self._require_target_exists(kind, body.target_slug)

        existing_stmt = select(Bookmark).where(
            Bookmark.user_id == user_id,
            Bookmark.target_kind == kind.value,
            Bookmark.target_slug == body.target_slug,
        )
        existing_row = (await self.session.exec(existing_stmt)).first()
        existing: Bookmark | None = existing_row[0] if existing_row is not None else None
        if existing is not None:
            # Treat re-saves as a no-op so the FE doesn't have to branch.
            return await self._project(existing)

        bookmark = Bookmark(
            user_id=user_id,
            target_kind=kind.value,
            target_slug=body.target_slug,
            note=body.note,
        )
        self.session.add(bookmark)
        try:
            await self.session.commit()
        except IntegrityError:
            # Race: another request just inserted the same pair.
            await self.session.rollback()
            existing_row = (await self.session.exec(existing_stmt)).first()
            existing = existing_row[0] if existing_row is not None else None
            if existing is None:
                raise
            return await self._project(existing)
        await self.session.refresh(bookmark)
        return await self._project(bookmark)

    async def delete(self, user_id: UUID, bookmark_id: UUID) -> None:
        """Remove one bookmark. Raises ``BookmarkNotFoundError`` when nothing matches."""
        stmt = delete(Bookmark).where(Bookmark.id == bookmark_id, Bookmark.user_id == user_id)
        result = await self.session.exec(stmt)  # type: ignore[call-overload]
        await self.session.commit()
        if getattr(result, "rowcount", 0) == 0:
            raise BookmarkNotFoundError()

    async def _project(self, bm: Bookmark) -> BookmarkOut:
        titles = await self._resolve_titles(bm.target_kind, bm.target_slug)
        return BookmarkOut(
            id=bm.id,
            target_kind=bm.target_kind,  # type: ignore[arg-type]
            target_slug=bm.target_slug,
            target_title=titles[0],
            target_title_ar=titles[1],
            target_title_fr=titles[2],
            note=bm.note,
            created_at=bm.created_at,
        )

    async def _require_target_exists(self, kind: BookmarkTargetKind, slug: str) -> None:
        if not await self._target_exists(kind, slug):
            raise BookmarkTargetNotFoundError(kind.value, slug)

    async def _target_exists(self, kind: BookmarkTargetKind, slug: str) -> bool:
        table = _TARGET_TABLE[kind]
        stmt = select(table.id).where(table.slug == slug).limit(1)  # type: ignore[attr-defined]
        return (await self.session.exec(stmt)).first() is not None

    async def _resolve_titles(self, kind: str, slug: str) -> tuple[str | None, str | None, str | None]:
        try:
            target_kind = BookmarkTargetKind(kind)
        except ValueError:
            return (None, None, None)
        table = _TARGET_TABLE[target_kind]
        if target_kind is BookmarkTargetKind.PERSON:
            stmt = select(Person.full_name_en, Person.full_name_ar, None).where(Person.slug == slug)
        elif target_kind is BookmarkTargetKind.OBSERVANCE:
            stmt = select(Observance.name_en, Observance.name_ar, Observance.name_fr).where(Observance.slug == slug)
        else:
            stmt = select(table.title_en, table.title_ar, table.title_fr).where(table.slug == slug)  # type: ignore[attr-defined]
        row = (await self.session.exec(stmt)).first()
        if row is None:
            return (None, None, None)
        # SQLModel's AsyncSession returns rows as tuples for column-tuple selects.
        en, ar, fr = row[0], row[1], row[2] if len(row) > 2 else None
        return (en, ar, fr)
