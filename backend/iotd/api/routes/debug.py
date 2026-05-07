"""Debug endpoints — verify that observability is wired end-to-end.

Visit ``/api/v1/_debug/crash`` to throw an unhandled exception that
bubbles up through the FastAPI exception handler in ``app.py`` and
lands in GlitchTip via the Sentry SDK. ``/_debug/log-warning`` exercises
the loguru → Sentry sink path instead of the unhandled-exception path.

The backend is not publicly reachable (only the frontend talks to it
through the same-origin proxy), so URL-level obscurity is enough for
these test triggers — no auth gate needed. Registered unconditionally
so a one-shot prod verification works without redeploys.
"""

from fastapi import APIRouter
from loguru import logger

router = APIRouter(prefix="/_debug", tags=["debug"], include_in_schema=False)


@router.get("/crash")
async def crash() -> dict[str, str]:
    """Throw — should produce an issue in GlitchTip / iotd-backend."""
    raise RuntimeError("[iotd] /_debug/crash test exception")


@router.get("/log-warning")
async def log_warning() -> dict[str, str]:
    """Emit a WARNING — should land in GlitchTip via the loguru sink."""
    logger.bind(probe="glitchtip").warning("[iotd] /_debug/log-warning probe")
    return {"status": "warned"}
