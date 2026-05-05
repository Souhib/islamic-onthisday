"""Async SQLAlchemy engine + session factory.

The data-pipeline writes the source SQLite database; this backend reads from
it. When PostgreSQL replaces SQLite in production, only ``database_url``
changes — the rest of this module is unchanged.
"""

from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncEngine, async_sessionmaker, create_async_engine
from sqlalchemy.pool import AsyncAdaptedQueuePool
from sqlmodel import SQLModel
from sqlmodel.ext.asyncio.session import AsyncSession

import iotd.models.user  # noqa: F401 — registers backend tables on SQLModel.metadata
from iotd.settings import Settings

_engine: AsyncEngine | None = None
_session_factory: async_sessionmaker[AsyncSession] | None = None


def _build_engine(settings: Settings) -> AsyncEngine:
    """Create the async engine for ``settings.database_url``.

    SQLite uses the default in-memory pool with ``check_same_thread=False``
    (aiosqlite requirement). Anything else assumes a server (PostgreSQL via
    asyncpg) and uses a tuned ``AsyncAdaptedQueuePool`` so we don't lean on
    SQLAlchemy's defaults in production.
    """
    if settings.database_url.startswith("sqlite"):
        return create_async_engine(
            settings.database_url,
            echo=False,
            future=True,
            connect_args={"check_same_thread": False},
        )
    return create_async_engine(
        settings.database_url,
        echo=False,
        future=True,
        poolclass=AsyncAdaptedQueuePool,
        pool_size=settings.db_pool_size,
        max_overflow=settings.db_max_overflow,
        pool_timeout=settings.db_pool_timeout,
        pool_recycle=settings.db_pool_recycle,
        pool_pre_ping=True,
    )


_BACKEND_TABLES: tuple[str, ...] = ("users", "bookmarks", "password_reset_tokens")


async def _create_backend_tables(engine: AsyncEngine) -> None:
    """Create the backend-owned tables (``users``, ``bookmarks``) if missing.

    The pipeline owns content-table DDL and rebuilds it from YAML on every
    run; backend tables are never touched by the pipeline (they're
    excluded from ``CONTENT_TABLE_NAMES``). Until Alembic lands in prod,
    we create them idempotently on each app boot — ``create_all`` is a
    no-op when the table already exists.
    """
    backend_tables = [SQLModel.metadata.tables[name] for name in _BACKEND_TABLES if name in SQLModel.metadata.tables]
    if not backend_tables:
        return
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all, tables=backend_tables)


async def init_engine(settings: Settings) -> AsyncEngine:
    """Build (once) and return the async engine.

    Also creates the backend-owned tables (``users``, ``bookmarks``) if
    they don't already exist — pipeline rebuilds never touch them.

    Args:
        settings: The active configuration.

    Returns:
        The shared ``AsyncEngine`` for the process.
    """
    global _engine, _session_factory  # noqa: PLW0603 — module-singleton, set once at startup
    if _engine is None:
        _engine = _build_engine(settings)
        _session_factory = async_sessionmaker(_engine, class_=AsyncSession, expire_on_commit=False)
        await _create_backend_tables(_engine)
    return _engine


async def dispose_engine() -> None:
    """Tear down the engine and reset module-level state.

    Called from the FastAPI lifespan shutdown handler so reload-friendly
    test runs don't leak connections.
    """
    global _engine, _session_factory  # noqa: PLW0603 — module-singleton, reset at shutdown
    if _engine is not None:
        await _engine.dispose()
    _engine = None
    _session_factory = None


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """Yield an ``AsyncSession`` bound to the shared engine.

    Used as a FastAPI dependency. The session rolls back on exception so a
    future write path doesn't leak partial state, and is closed automatically
    when the request finishes.

    Yields:
        An open ``AsyncSession``.
    """
    if _session_factory is None:
        raise RuntimeError("Database engine not initialised. Call init_engine() in the app lifespan.")
    async with _session_factory() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
