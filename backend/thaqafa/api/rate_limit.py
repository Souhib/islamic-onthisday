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

import os
from collections.abc import Callable

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter  # noqa: PLC2701
from slowapi import _rate_limit_exceeded_handler as _slowapi_default_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from thaqafa.settings import Settings

# Module-level enabled flag — read from env at import time so the
# Limiter can be constructed with the right `enabled=` kwarg before
# any route module imports it for the decorator. Mirrors the LaTabdhir
# / Majlisna pattern: when disabled (tests, local dev), the decorators
# short-circuit instead of raising on missing app.state.limiter.
_enabled = os.environ.get("RATE_LIMIT_ENABLED", "false").lower() not in (
    "false",
    "0",
    "no",
)

# Global default — generous enough for ordinary humans (one request per
# second on average), tight enough that scraping the whole 1256-event
# corpus from a single IP takes ~21 minutes instead of a few seconds.
PUBLIC_API_LIMIT = "60/minute"

# Stricter per-IP caps for credential-handling routes. A real user logs
# in maybe twice in their life on a given IP; a bot guessing passwords
# tries thousands. 10/min is comfortable for the human and cuts a brute-
# force attempt by 99 %+ at the edge before it even reaches the password
# hasher.
AUTH_TIGHT_LIMIT = "10/minute"
# Mailer-dispatching routes get an even tighter cap — sending password-
# reset / verification mail costs us per-call (Resend); abusers can also
# weaponise it to spam a victim's inbox.
AUTH_MAILER_LIMIT = "3/minute"

# Module-level Limiter so routes can apply per-route decorators like
# ``@limiter.limit(AUTH_TIGHT_LIMIT)``. Constructed eagerly with the
# global default; ``configure_rate_limit`` wires it to the app on
# startup. When ``settings.rate_limit_enabled`` is false the limiter
# still exists but its decorators short-circuit (the middleware isn't
# installed, so no enforcement).
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[PUBLIC_API_LIMIT],
    enabled=_enabled,
    # ``headers_enabled`` left at the default (False). Enabling it
    # forces every per-route ``@limiter.limit(...)`` decorator to declare
    # a ``response: Response`` param so slowapi can inject the
    # ``X-RateLimit-*`` headers — that's a Response we don't otherwise
    # need on Token-returning routes. Clients still receive a clean
    # 429 envelope on overflow; that's enough enforcement.
)


def configure_rate_limit(app: FastAPI, settings: Settings) -> Limiter | None:
    """Wire slowapi to the app, returning the Limiter for routes to use.

    When disabled (tests, local dev), returns ``None`` and skips the
    middleware install.
    """
    if not settings.rate_limit_enabled:
        return None
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
    app.add_middleware(SlowAPIMiddleware)
    return limiter


def _rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    """Replace slowapi's default 429 body with our error envelope shape."""
    # Reuse slowapi's header-setting machinery, then unify the JSON body.
    response = _slowapi_default_handler(request, exc)
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
