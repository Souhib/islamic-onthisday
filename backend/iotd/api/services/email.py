"""Transactional email — thin Resend wrapper.

The function is gated on ``settings.resend_api_key`` (same pattern as the
Sentry DSN): when the key is empty we log the would-be send at INFO and
return without hitting the network, so dev runs and the test suite stay
offline by default.

Templates are kept inline as plain ``str`` builders rather than Jinja2
files — there are only a couple, the editorial vocabulary is stable, and
keeping them in Python avoids an extra runtime dependency for what is
essentially a one-paragraph header + body + button.
"""

from collections.abc import Callable
from typing import Any

import resend
from loguru import logger

from iotd.settings import Settings


def _format_from(settings: Settings) -> str:
    return f"{settings.email_from_name} <{settings.email_from_address}>"


# Indirection so tests can monkeypatch the underlying call without having
# to reach into the resend SDK module structure. Production wires this to
# ``resend.Emails.send``.
_send_resend: Callable[[dict[str, Any]], Any] | None = None


def _resolve_send() -> Callable[[dict[str, Any]], Any]:
    global _send_resend  # noqa: PLW0603 — module-level lazy bind
    if _send_resend is None:
        _send_resend = resend.Emails.send  # type: ignore[attr-defined]
    return _send_resend


def send_email(
    *,
    to: str,
    subject: str,
    html: str,
    text: str | None = None,
    settings: Settings,
) -> None:
    """Send a single transactional email via Resend.

    Args:
        to: Recipient address.
        subject: Subject line. Plain string, no MIME encoding required —
            Resend handles UTF-8 transparently.
        html: HTML body. Wrap text in editorial typography helpers
            elsewhere; this layer is content-agnostic.
        text: Optional plain-text alternative. Some clients (and most spam
            filters) prefer a multipart message that ships both formats.
        settings: Pulled in via the controller so tests can inject a fake.

    Raises:
        Nothing on the happy path. Resend SDK errors propagate as plain
        exceptions; callers can catch + degrade gracefully if they want a
        background-style "fire and forget" semantics.
    """
    if not settings.resend_api_key:
        logger.bind(to=to, subject=subject).info("email_skipped_no_resend_api_key")
        return

    resend.api_key = settings.resend_api_key

    payload: dict[str, Any] = {
        "from": _format_from(settings),
        "to": [to],
        "subject": subject,
        "html": html,
    }
    if text:
        payload["text"] = text

    try:
        _resolve_send()(payload)
        logger.bind(to=to, subject=subject).info("email_sent")
    except Exception:
        logger.bind(to=to, subject=subject).exception("email_send_failed")
        raise
