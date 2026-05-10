"""Async SQLAlchemy engine + session factory.

The pipeline writes the dataset to the same database this backend reads
from. The connection URL is taken verbatim from ``settings.database_url``
and normalised to an async driver — bare ``postgresql://`` becomes
``postgresql+asyncpg://``, bare ``sqlite:///`` becomes
``sqlite+aiosqlite:///``. SQLite is the dev/test path; PostgreSQL is
production.
"""

from collections.abc import AsyncGenerator

from sqlalchemy.engine.url import make_url
from sqlalchemy.ext.asyncio import AsyncEngine, async_sessionmaker, create_async_engine
from sqlalchemy.pool import AsyncAdaptedQueuePool
from sqlmodel import SQLModel
from sqlmodel.ext.asyncio.session import AsyncSession

import thaqafa.models.user  # noqa: F401 — registers backend tables on SQLModel.metadata
from thaqafa.settings import Settings

_engine: AsyncEngine | None = None
_session_factory: async_sessionmaker[AsyncSession] | None = None


def _to_async_url(url: str) -> str:
    """Normalise a SQLAlchemy URL to an async driver. Idempotent.

    ``postgresql://…`` and ``postgresql+psycopg://…`` become
    ``postgresql+asyncpg://…``; ``sqlite:///…`` becomes
    ``sqlite+aiosqlite:///…``; URLs that already specify an async driver
    pass through unchanged.
    """
    parsed = make_url(url)
    backend = parsed.get_backend_name()
    if backend == "postgresql":
        return parsed.set(drivername="postgresql+asyncpg").render_as_string(hide_password=False)
    if backend == "sqlite":
        return parsed.set(drivername="sqlite+aiosqlite").render_as_string(hide_password=False)
    return url


def _build_engine(settings: Settings) -> AsyncEngine:
    """Create the async engine for ``settings.database_url``.

    SQLite uses the default in-memory pool with ``check_same_thread=False``
    (aiosqlite requirement). PostgreSQL assumes a remote server (asyncpg)
    and uses a tuned ``AsyncAdaptedQueuePool``.
    """
    url = _to_async_url(settings.database_url)
    if url.startswith("sqlite"):
        return create_async_engine(
            url,
            echo=False,
            future=True,
            connect_args={"check_same_thread": False},
        )
    return create_async_engine(
        url,
        echo=False,
        future=True,
        poolclass=AsyncAdaptedQueuePool,
        pool_size=settings.db_pool_size,
        max_overflow=settings.db_max_overflow,
        pool_timeout=settings.db_pool_timeout,
        pool_recycle=settings.db_pool_recycle,
        pool_pre_ping=True,
    )


_BACKEND_TABLES: tuple[str, ...] = (
    "users",
    "bookmarks",
    "password_reset_tokens",
    "email_verification_tokens",
    "email_change_tokens",
)


async def _create_backend_tables(engine: AsyncEngine) -> None:
    """Create the backend-owned tables idempotently.

    The pipeline owns content-table DDL and rebuilds it from YAML on every
    run; backend tables are excluded from ``CONTENT_TABLE_NAMES`` and
    never touched. ``create_all`` is a no-op when a table already exists.
    Schema evolution will move to Alembic; for now (postgres-fresh deploy
    + curator-driven content) ``create_all`` is enough.
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
