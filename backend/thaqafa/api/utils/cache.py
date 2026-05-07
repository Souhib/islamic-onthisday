"""Simple in-memory TTL cache for near-static read-only data.

Avoids redundant DB queries for endpoints that recompute the same payload
on every request (``/today``, ``/recent``, ``/observances``). The dataset
only changes when the pipeline rebuilds, so caching for minutes-to-hours
on the same process is safe even without an explicit invalidation hook.

Lifted from the pattern in Majlisna (``IPG/.../api/utils/cache.py``) with
two adaptations: per-call ``ttl_seconds`` overrides (so a single instance
can serve multiple cadences) and a ``invalidate_prefix`` helper for
"flush everything matching ``today:*``".

Not thread-safe in the strict sense — Python's GIL makes dict
``get``/``set`` atomic, but composite "check then set" sequences are not.
That's fine for our use case (idempotent regenerations) and would only
matter under heavy contention.
"""

import time
from typing import Any


class TTLCache:
    """Dict-based TTL cache using monotonic clock.

    Args:
        ttl_seconds: Default time-to-live for entries that don't override.
    """

    def __init__(self, ttl_seconds: float = 60.0) -> None:
        self._default_ttl = ttl_seconds
        self._store: dict[str, tuple[float, Any]] = {}

    def get(self, key: str) -> Any | None:
        """Return the cached value or ``None`` if missing / expired.

        Expired entries are evicted on read so the store doesn't grow
        unboundedly under churn.
        """
        entry = self._store.get(key)
        if entry is None:
            return None
        expires_at, value = entry
        if time.monotonic() > expires_at:
            del self._store[key]
            return None
        return value

    def set(self, key: str, value: Any, *, ttl_seconds: float | None = None) -> None:
        """Cache ``value`` under ``key`` for ``ttl_seconds`` (or the default)."""
        ttl = self._default_ttl if ttl_seconds is None else ttl_seconds
        self._store[key] = (time.monotonic() + ttl, value)

    def invalidate(self, key: str) -> None:
        """Remove a specific key. Silently no-ops when the key isn't set."""
        self._store.pop(key, None)

    def invalidate_prefix(self, prefix: str) -> None:
        """Drop every key starting with ``prefix``. Useful for ``today:*``."""
        for key in [k for k in self._store if k.startswith(prefix)]:
            del self._store[key]

    def clear(self) -> None:
        """Drop every entry. Mostly useful in tests."""
        self._store.clear()
