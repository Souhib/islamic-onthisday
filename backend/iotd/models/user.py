"""User + Bookmark tables.

These rows are user-generated, not content-pipeline output, so they live
in the backend package and are intentionally excluded from
``pipeline.constants.CONTENT_TABLE_NAMES`` — never dropped on rebuild.

A bookmark points at any of: an event, a lesson, an observance, or a
person. The polymorphic ``target_kind`` + ``target_slug`` pair is the
practical model for a read-only catalogue: there are no cascading
foreign keys to break when the dataset is rebuilt and a slug temporarily
disappears, and the backend can validate the slug exists at create time.
"""

from datetime import UTC, datetime
from enum import StrEnum
from uuid import UUID, uuid4

from sqlalchemy import TIMESTAMP, UniqueConstraint
from sqlmodel import Field, Relationship, SQLModel


class BookmarkTargetKind(StrEnum):
    """The four resource kinds a user can bookmark."""

    EVENT = "event"
    LESSON = "lesson"
    OBSERVANCE = "observance"
    PERSON = "person"


class User(SQLModel, table=True):
    """Authenticated account. Email is the canonical identifier.

    Passwords are stored as Argon2 hashes via ``iotd.api.services.auth``;
    the raw password never leaves the request handler.
    """

    __tablename__ = "users"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(max_length=255, unique=True, index=True)
    password_hash: str = Field(max_length=255)
    display_name: str | None = Field(default=None, max_length=64)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )
    last_login_at: datetime | None = Field(
        default=None,
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )

    bookmarks: list["Bookmark"] = Relationship(
        back_populates="user",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )


class Bookmark(SQLModel, table=True):
    """A user's saved reference to one piece of content.

    The ``(user_id, target_kind, target_slug)`` triple is unique — saving
    the same item twice is a no-op rather than a duplicate row.
    """

    __tablename__ = "bookmarks"
    __table_args__ = (UniqueConstraint("user_id", "target_kind", "target_slug"),)

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    target_kind: str = Field(max_length=16, index=True)
    target_slug: str = Field(max_length=160, index=True)
    note: str | None = Field(default=None, max_length=512)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )

    user: User = Relationship(back_populates="bookmarks")


class PasswordResetToken(SQLModel, table=True):
    """One-time token issued to allow a password reset via emailed link.

    The token itself is the primary key (a uuid4 hex slug) — there is no
    separate id column. We store an expiry instead of a ``valid`` flag so
    the table can be cleaned up by date later, and a ``used_at`` timestamp
    so reuse is rejected even before expiry kicks in.
    """

    __tablename__ = "password_reset_tokens"

    token: str = Field(max_length=64, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    expires_at: datetime = Field(
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )
    used_at: datetime | None = Field(
        default=None,
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        sa_type=TIMESTAMP(timezone=True),  # type: ignore[invalid-argument-type]
    )
