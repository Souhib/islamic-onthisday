"""Per-IP rate limiting for the public read API.

Cloudflare already absorbs DDoS at the edge, but app-level limits on
``/api/v1/*`` keep a polite scraper from exfiltrating the curated
dataset in one minute. The dataset is the project's main asset; the
limit is a belt to CF's suspenders.

Implementation notes:

- ``slowapi`` is the de-facto rate-limit lib for Starlette/FastAPI; we
  pick it for the zero-extra-deps story (no Redis, in-process counters).
  Single-process is fine for the current scale.
- The limiter is gated on ``settings.rate_limit_enabled`` so tests don't
  flake on it. The limiter object is built once at app startup; routes
  attach to it via the ``Depends(get_rate_limit)`` pattern.
- We pin Cloudflare-style remote-IP detection: behind the CF + Traefik
  chain, the client IP shows up in ``X-Forwarded-For``. ``starlette``'s
  ``get_remote_address`` already prefers it, so default behaviour is
  correct.
"""

from collections.abc import Callable

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from iotd.settings import Settings

# Global default — generous enough for ordinary humans (one request per
# second on average), tight enough that scraping the whole 1256-event
# corpus from a single IP takes ~21 minutes instead of a few seconds.
PUBLIC_API_LIMIT = "60/minute"


def configure_rate_limit(app: FastAPI, settings: Settings) -> Limiter | None:
    """Wire slowapi to the app, returning the Limiter for routes to use.

    When disabled (tests, local dev), returns ``None`` and skips the
    middleware install.
    """
    if not settings.rate_limit_enabled:
        return None
    limiter = Limiter(
        key_func=get_remote_address,
        default_limits=[PUBLIC_API_LIMIT],
        headers_enabled=True,
    )
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler_iotd)
    app.add_middleware(SlowAPIMiddleware)
    return limiter


def _rate_limit_exceeded_handler_iotd(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    """Replace slowapi's default 429 body with our error envelope shape."""
    # Reuse slowapi's header-setting machinery, then unify the JSON body.
    response = _rate_limit_exceeded_handler(request, exc)
    return JSONResponse(
        status_code=response.status_code,
        headers=dict(response.headers),
        content={
            "error": "RateLimitExceeded",
            "error_key": "errors.api.rateLimit",
            "message": "Too many requests. Please slow down.",
            "error_params": None,
            "details": {"limit": str(exc.detail) if hasattr(exc, "detail") else PUBLIC_API_LIMIT},
        },
    )


def public_limit() -> Callable[[Request], None]:
    """Dependency-shaped no-op so route signatures stay consistent
    whether the global limiter is on or off.

    The actual enforcement happens via the :class:`SlowAPIMiddleware`
    on the app instance — this is here only to make it explicit at the
    route level which paths are subject to the public read limit, in
    case we want a stricter per-route rate later.
    """

    def _noop(_: Request) -> None:
        return None

    return _noop
