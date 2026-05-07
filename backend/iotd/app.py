"""FastAPI app factory.

Builds the application object with middleware, routers, and a lifespan hook
that initialises the async DB engine. The Majlisna pattern: a single
``create_app`` call so tests can build a fresh app without reusing process
state, and ``main.py`` wires it to uvicorn.
"""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from datetime import UTC, datetime
from uuid import UUID

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from loguru import logger

from iotd.api.errors import BaseError
from iotd.api.middleware import LoggingMiddleware, RequestIDMiddleware, SecurityMiddleware
from iotd.api.rate_limit import configure_rate_limit
from iotd.api.routes import auth as auth_route
from iotd.api.routes import bookmarks as bookmarks_route
from iotd.api.routes import debug as debug_route
from iotd.api.routes import events as events_route
from iotd.api.routes import health as health_route
from iotd.api.routes import lessons as lessons_route
from iotd.api.routes import observances as observances_route
from iotd.api.routes import people as people_route
from iotd.api.routes import recent as recent_route
from iotd.api.routes import today as today_route
from iotd.api.routes import upcoming as upcoming_route
from iotd.database import dispose_engine, init_engine
from iotd.logger_config import configure_logger
from iotd.observability import configure_sentry
from iotd.settings import Settings, get_settings
from iotd.version import __version__

# 4xx codes where field-level details (the offending slug, query param, …)
# are useful for the front-end's error UX. 5xx never includes details.
_DETAILS_STATUS_CODES = frozenset({400, 404, 409, 422, 429})


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build and return the FastAPI app.

    Args:
        settings: Optional pre-built settings — useful when a test rig wants
            to inject a different DB URL. Defaults to ``get_settings()``.

    Returns:
        The wired ``FastAPI`` instance.
    """
    settings = settings or get_settings()
    configure_logger(settings.log_level, serialize=settings.log_serialize)
    configure_sentry(settings)
    is_production = settings.iotd_env == "production"

    @asynccontextmanager
    async def lifespan(_: FastAPI) -> AsyncIterator[None]:
        await init_engine(settings)
        logger.bind(env=settings.iotd_env, port=settings.port).info("api_started")
        try:
            yield
        finally:
            await dispose_engine()
            logger.info("api_stopped")

    app = FastAPI(
        title="Islamic On This Day",
        version=__version__,
        description=(
            "Read-only API serving one verified Islamic-history event per day, in "
            "both Hijri and Gregorian calendars. Backed by the data-pipeline's "
            "curated SQLite database."
        ),
        lifespan=lifespan,
    )

    # Middleware order: first added = outermost. Security runs first (cheap
    # rejects + sanitisation), then RequestID (so logging can correlate),
    # then logging, then CORS (browser-facing).
    app.add_middleware(SecurityMiddleware, is_production=is_production)
    app.add_middleware(RequestIDMiddleware)
    app.add_middleware(LoggingMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["GET", "POST", "DELETE"],
        allow_headers=["*"],
    )

    # slowapi installs its own ASGI middleware; gate on the env flag so
    # the per-IP counters don't fire on every test.
    configure_rate_limit(app, settings)

    @app.exception_handler(BaseError)
    async def _base_error_handler(_request: Request, exc: BaseError) -> JSONResponse:
        include_details = exc.status_code in _DETAILS_STATUS_CODES
        details = {k: str(v) if isinstance(v, UUID) else v for k, v in exc.details.items()} if include_details else {}
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": exc.error_code,
                "error_key": exc.error_key,
                "message": exc.frontend_message,
                "error_params": exc.error_params,
                "details": details,
                "timestamp": exc.timestamp.isoformat(),
            },
        )

    @app.exception_handler(RequestValidationError)
    async def _request_validation_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        logger.bind(path=request.url.path, method=request.method).warning("request_validation_failed")
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "error": "ValidationError",
                "error_key": "errors.api.validation",
                "message": "Invalid request data. Please check your input.",
                "error_params": None,
                "details": exc.errors(),
                "timestamp": datetime.now(UTC).isoformat(),
            },
        )

    @app.exception_handler(Exception)
    async def _general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.bind(
            error=exc.__class__.__name__,
            message=str(exc),
            path=request.url.path,
            method=request.method,
        ).exception("unexpected_server_error")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "error": "InternalServerError",
                "error_key": "errors.api.internalServer",
                "message": "Something went wrong on our end. Please try again later.",
                "error_params": None,
                "details": {},
                "timestamp": datetime.now(UTC).isoformat(),
            },
        )

    # Health lives under ``/api/v1/health`` like every other route — the
    # nginx proxy at ``location /api/`` is what makes it reachable from
    # outside (``/health`` at the public origin is shadowed by nginx's
    # own static liveness probe for the FE container).
    app.include_router(health_route.router, prefix="/api/v1")
    app.include_router(today_route.router, prefix="/api/v1")
    app.include_router(events_route.router, prefix="/api/v1")
    app.include_router(lessons_route.router, prefix="/api/v1")
    app.include_router(observances_route.router, prefix="/api/v1")
    app.include_router(people_route.router, prefix="/api/v1")
    app.include_router(recent_route.router, prefix="/api/v1")
    app.include_router(upcoming_route.router, prefix="/api/v1")
    app.include_router(auth_route.router, prefix="/api/v1")
    app.include_router(bookmarks_route.router, prefix="/api/v1")
    app.include_router(debug_route.router, prefix="/api/v1")

    return app


app = create_app()
