"""Database engine and session management for the pipeline.

Synchronous counterpart to the backend's async database layer. The
pipeline is a batch ingestion script and does not need async I/O; the
schema and session idioms are otherwise identical.

**Single-database constraint.** The pipeline shares its database with
the backend: dataset tables (events, lessons, …) AND user tables
(accounts, bookmarks, …) live side by side. ``init_db`` is therefore
*scoped* — it only drops the tables listed in
:data:`pipeline.constants.CONTENT_TABLE_NAMES`. User data is never
touched, even when the pipeline runs a full rebuild.

**URL resolution.** The connection URL is read from
``THAQAFA_DATABASE_URL`` (env). It can be any SQLAlchemy URL —
``postgresql://``, ``postgresql+psycopg://``, ``postgresql+asyncpg://``,
``sqlite:///`` — we normalise it to a sync driver. When the env var is
absent we fall back to the bundled SQLite file at
:data:`pipeline.constants.DEFAULT_DB_PATH` so ``python -m pipeline.build``
keeps working out of the box for local dev.
"""

import os
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

from sqlalchemy import Engine, Table, create_engine, text
from sqlalchemy.engine.url import make_url
from sqlmodel import Session, SQLModel

from pipeline import models as _models  # noqa: F401  — register tables on metadata
from pipeline.constants import CONTENT_TABLE_NAMES, DEFAULT_DB_PATH

_engine: Engine | None = None


def _to_sync_url(url: str) -> str:
    """Normalise a SQLAlchemy URL to a sync driver.

    ``postgresql+asyncpg://…`` and bare ``postgresql://…`` both become
    ``postgresql+psycopg://…``. ``sqlite+aiosqlite:///…`` becomes
    ``sqlite:///…``. Already-sync URLs pass through unchanged. Idempotent.
    """
    parsed = make_url(url)
    backend = parsed.get_backend_name()
    if backend == "postgresql":
        return parsed.set(drivername="postgresql+psycopg").render_as_string(hide_password=False)
    if backend == "sqlite":
        return parsed.set(drivername="sqlite").render_as_string(hide_password=False)
    return url


def _resolve_url(db_path: Path | None) -> str:
    """Pick the connection URL for the pipeline.

    Precedence:
        1. ``db_path`` argument (callers that want to point at a specific file).
        2. ``THAQAFA_DATABASE_URL`` env var (prod / docker-compose / explicit).
        3. The bundled SQLite at :data:`DEFAULT_DB_PATH` (local dev fallback).
    """
    if db_path is not None:
        db_path.parent.mkdir(parents=True, exist_ok=True)
        return f"sqlite:///{db_path}"
    env_url = os.environ.get("THAQAFA_DATABASE_URL")
    if env_url:
        return _to_sync_url(env_url)
    DEFAULT_DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    return f"sqlite:///{DEFAULT_DB_PATH}"


def create_app_engine(db_path: Path | None = None) -> Engine:
    """Create a synchronous SQLAlchemy engine for the pipeline database.

    Args:
        db_path: Override pointing at a specific on-disk SQLite path.
            Mostly used by tests / local one-offs. In prod the URL comes
            from ``THAQAFA_DATABASE_URL``.

    Returns:
        A configured SQLAlchemy :class:`Engine`.
    """
    return create_engine(
        _resolve_url(db_path),
        echo=False,
        future=True,
        pool_pre_ping=True,
    )


def get_engine(db_path: Path | None = None) -> Engine:
    """Return the process-wide engine singleton, creating it on first use.

    Args:
        db_path: Optional path override passed on to :func:`create_app_engine`.

    Returns:
        The shared :class:`Engine` instance.
    """
    global _engine  # noqa: PLW0603
    if _engine is None:
        _engine = create_app_engine(db_path)
    return _engine


def _content_tables() -> list[Table]:
    """Return the SQLAlchemy ``Table`` objects for every content table.

    Filters by ``__tablename__`` against :data:`CONTENT_TABLE_NAMES`. Any
    table on ``SQLModel.metadata`` whose name isn't in the allowlist
    (e.g. a future ``users`` table) is skipped — the pipeline never
    touches it.
    """
    return [SQLModel.metadata.tables[name] for name in CONTENT_TABLE_NAMES if name in SQLModel.metadata.tables]


def create_db_and_tables(engine: Engine, drop_all: bool = False) -> None:
    """Create (or recreate) the **content** tables. User tables are untouched.

    Args:
        engine: The SQLAlchemy engine to run DDL against.
        drop_all: When ``True``, drop the content tables before creating
            them. SQLAlchemy resolves drop order topologically given the
            ``tables=`` argument, so foreign-key dependencies are honoured.
    """
    tables = _content_tables()
    if drop_all:
        SQLModel.metadata.drop_all(engine, tables=tables)
    SQLModel.metadata.create_all(engine, tables=tables)
    if "sqlite" in str(engine.url):
        with engine.begin() as conn:
            conn.execute(text("PRAGMA foreign_keys=ON"))


def init_db(db_path: Path | None = None) -> None:
    """Drop and recreate the content tables. Convenience wrapper for rebuilds.

    User tables (when they land) are explicitly **not** affected — see
    :data:`pipeline.constants.CONTENT_TABLE_NAMES` for the allowlist.

    Args:
        db_path: Optional path override (see :func:`create_app_engine`).
    """
    engine = get_engine(db_path)
    create_db_and_tables(engine, drop_all=True)


@contextmanager
def session_scope(db_path: Path | None = None) -> Iterator[Session]:
    """Open a :class:`sqlmodel.Session`; commit on exit, rollback on exception.

    Args:
        db_path: Optional path override (see :func:`create_app_engine`).

    Yields:
        An open SQLModel :class:`Session` usable inside a ``with`` block.
    """
    engine = get_engine(db_path)
    session = Session(engine)
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
