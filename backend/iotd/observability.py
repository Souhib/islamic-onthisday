"""Observability glue — Sentry init, gated by env.

When ``SENTRY_DSN`` is empty (the default) ``configure_sentry`` is a
no-op — zero overhead in dev. Production deployments set the DSN via
environment and we wire the Starlette integration plus a loguru sink
that forwards WARNING+ events as Sentry messages and any
``logger.exception()`` payload as a Sentry exception.

Ports the Majlisna pattern (``IPG/.../app.py:_configure_observability``)
without dragging in Logfire — IOTD doesn't run an experiment surface that
needs spans of its own yet.
"""

from typing import Any

import sentry_sdk
from loguru import logger
from sentry_sdk.integrations.starlette import StarletteIntegration

from iotd import __version__
from iotd.settings import Settings


def configure_sentry(settings: Settings) -> None:
    """Initialise Sentry if a DSN is configured. No-op otherwise.

    The SDK is imported at module load (so import errors surface up
    front, not at first request) but ``sentry_sdk.init`` only fires
    when ``settings.sentry_dsn`` is set. Without a DSN the SDK is
    dormant — no network, no instrumentation, no breadcrumbs.
    """
    if not settings.sentry_dsn:
        return

    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        environment=settings.iotd_env,
        traces_sample_rate=settings.sentry_traces_sample_rate,
        # Default integrations cover Starlette (which FastAPI extends),
        # asyncio, and stdlib loggers.
        integrations=[StarletteIntegration()],
        release=f"iotd-api@{__version__}",
    )
    logger.add(_sentry_sink, level="WARNING")


def _sentry_sink(message: Any) -> None:
    """Loguru sink that forwards WARNING+ records to Sentry.

    - WARNING+ records become Sentry messages.
    - ``logger.exception()`` records (which carry a real traceback) become
      Sentry exceptions for full stack capture.
    """
    record = message.record
    if record["level"].no >= 30:  # WARNING
        sentry_sdk.capture_message(record["message"], level=record["level"].name.lower())

    if record["exception"] is not None:
        _, exc_value, _ = record["exception"]
        if exc_value is not None:
            sentry_sdk.capture_exception(exc_value)
