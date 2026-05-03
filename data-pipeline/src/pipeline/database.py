"""Database engine and session management for the pipeline.

Synchronous counterpart to Majlisna's async database layer. The pipeline is a
batch ingestion script and does not need async I/O; the schema and session
idioms are otherwise identical.

**Single-database constraint.** The pipeline's SQLite is shared with the
backend: dataset tables (events, lessons, …) AND any future user tables
(accounts, bookmarks, …) live side by side. ``init_db`` is therefore
*scoped* — it only drops the tables listed in
:data:`pipeline.constants.CONTENT_TABLE_NAMES`. User data is never
touched, even when the pipeline runs a full rebuild.
"""

from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

from sqlalchemy import Engine, Table, create_engine, text
from sqlmodel import Session, SQLModel

from pipeline import models as _models  # noqa: F401  — register tables on metadata
from pipeline.constants import CONTENT_TABLE_NAMES, DEFAULT_DB_PATH

_engine: Engine | None = None


def create_app_engine(db_path: Path | None = None) -> Engine:
    """Create a synchronous SQLAlchemy engine for the pipeline database.

    Args:
        db_path: Override for the on-disk SQLite path. Defaults to
            :data:`pipeline.constants.DEFAULT_DB_PATH`.

    Returns:
        A configured SQLAlchemy :class:`Engine`.
    """
    path = db_path or DEFAULT_DB_PATH
    path.parent.mkdir(parents=True, exist_ok=True)
    return create_engine(
        f"sqlite:///{path}",
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
