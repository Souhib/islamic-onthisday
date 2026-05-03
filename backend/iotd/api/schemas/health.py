"""Response shape for ``GET /health``.

The health payload doubles as a lightweight ops dashboard: it surfaces row
counts and the dataset's age so an alert can fire when the pipeline hasn't
run in too long. Everything is optional — a degraded DB still returns a
valid envelope, just with the counts missing.
"""

from iotd.api.schemas.shared import ResponseModel


class DatasetSnapshot(ResponseModel):
    """Per-resource row counts + dataset freshness signal.

    ``built_at`` and ``age_hours`` come from the most recent ``updated_at``
    on the ``events`` table — that's the signal that a pipeline rebuild
    actually happened, even when no rows were added or removed.
    """

    event_count: int
    lesson_count: int
    observance_count: int
    person_count: int
    built_at: str | None = None  # ISO-8601 of the most recent Event.updated_at
    age_hours: float | None = None  # hours since built_at, computed at request time


class HealthResponse(ResponseModel):
    """Liveness + DB connectivity probe + dataset snapshot."""

    status: str  # "ok" | "degraded"
    database: str  # "ok" | "down"
    version: str
    dataset: DatasetSnapshot | None = None
