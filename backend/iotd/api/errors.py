"""Domain-level exceptions raised by controllers and translated to HTTP
responses by the FastAPI exception-handler layer.

Controllers must never import ``fastapi.HTTPException`` directly; raise a
domain error and let the handler in :mod:`iotd.app` shape the response.

The base class auto-derives a stable ``error_key`` from the subclass name
(``EventNotFoundError`` → ``errors.api.eventNotFound``) and self-logs at a
level chosen from the HTTP status code:

- 5xx → ``logger.error`` (always; internal failures need to surface)
- 401 / 403 / 409 → ``logger.warning`` (auth/UX/race signal once users land)
- 4xx (404, 400, 422, …) → ``logger.debug`` (normal user mistakes; off in
  prod by default — keeps the log stream clean for a public read-only API)

Subclasses can override ``log_level`` per-instance when the default isn't
right (e.g. an unusual 400 you actively want to monitor).
"""

import re
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from fastapi import status
from loguru import logger


class LogLevel(StrEnum):
    """Loguru level names, exposed as an enum so subclasses can be explicit."""

    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


_LOG_FUNCTIONS = {
    LogLevel.DEBUG: logger.debug,
    LogLevel.INFO: logger.info,
    LogLevel.WARNING: logger.warning,
    LogLevel.ERROR: logger.error,
    LogLevel.CRITICAL: logger.critical,
}


def _default_log_level(status_code: int) -> LogLevel:
    if status_code >= 500:
        return LogLevel.ERROR
    if status_code in (401, 403, 409):
        return LogLevel.WARNING
    return LogLevel.DEBUG


class BaseError(Exception):
    """Base class for all application-specific errors.

    Attributes:
        error_code: Machine-readable error identifier (e.g. ``"EventNotFoundError"``).
        error_key: I18n key used by the frontend to look up a translated message.
        frontend_message: Human-readable English fallback message.
        error_params: Optional dict of interpolation parameters for the i18n key.
        details: Optional dict of extra context (slugs, IDs, etc.).
        status_code: HTTP status code to return.
        timestamp: UTC timestamp when the error was raised.
        log_level: Resolved loguru level used at construction time.
    """

    def __init__(
        self,
        message: str,
        *,
        frontend_message: str | None = None,
        error_code: str | None = None,
        error_key: str | None = None,
        error_params: dict[str, Any] | None = None,
        details: dict[str, Any] | None = None,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        log_level: LogLevel | None = None,
        log: bool = True,
    ):
        self.message = message
        self.frontend_message = frontend_message or message
        self.status_code = status_code
        self.error_code = error_code or self.__class__.__name__
        self.error_key = error_key or self._generate_error_key()
        self.error_params = error_params or {}
        self.details = details or {}
        self.timestamp = datetime.now(UTC)
        self.log_level = log_level or _default_log_level(status_code)

        # ``log=False`` is the escape hatch when a caller raises an error
        # inside a try/except that's about to handle it locally — without
        # this, the error would log a "phantom" line even though it was
        # neutralised. Default ``True`` keeps the auto-log behaviour for
        # normal control flow (raise → handler → response).
        if log:
            _LOG_FUNCTIONS[self.log_level](
                f"{self.error_code}: {self.message}",
                error_code=self.error_code,
                status_code=self.status_code,
                details=self.details,
            )

        super().__init__(message)

    @classmethod
    def _generate_error_key(cls) -> str:
        """Derive ``errors.api.<camelCase>`` from the subclass name.

        Drops a trailing ``Error``, splits on capitals, lowercases the first
        token and capitalises the rest. ``EventNotFoundError`` →
        ``errors.api.eventNotFound``. Stable enough that the front-end can
        keep the i18n key map next to its locale files.
        """
        name = cls.__name__
        if name.endswith("Error"):
            name = name[:-5]
        if not name:
            return "errors.api.unknown"
        parts = re.findall(r"[A-Z][a-z0-9]*|[a-z0-9]+", name)
        if not parts:
            return f"errors.api.{name.lower()}"
        head = parts[0].lower()
        tail = "".join(p[:1].upper() + p[1:].lower() for p in parts[1:])
        return f"errors.api.{head}{tail}"


class NotFoundError(BaseError):
    """Generic 404 — prefer a typed subclass when possible."""

    def __init__(self, message: str, **kwargs: Any):
        kwargs.setdefault("status_code", status.HTTP_404_NOT_FOUND)
        super().__init__(message, **kwargs)


class ValidationError(BaseError):
    """Raised when request parameters fail validation rules beyond Pydantic's scope."""

    def __init__(self, message: str, **kwargs: Any):
        kwargs.setdefault("status_code", status.HTTP_422_UNPROCESSABLE_ENTITY)
        super().__init__(message, **kwargs)


# --- Resource-typed 404s ----------------------------------------------------
#
# One concrete class per resource. The frontend can switch on ``error_key``
# (``errors.api.eventNotFound`` etc.) and render a tailored message instead
# of a generic "not found." The ``details`` dict carries the slug so the
# frontend can offer a "back to browse" link or similar.


class EventNotFoundError(NotFoundError):
    """Raised when no :class:`Event` matches the requested slug."""

    def __init__(self, slug: str):
        super().__init__(
            message=f"event '{slug}' not found",
            frontend_message="That event doesn't exist.",
            details={"slug": slug},
        )


class LessonNotFoundError(NotFoundError):
    """Raised when no :class:`DatelessLesson` matches the requested slug."""

    def __init__(self, slug: str):
        super().__init__(
            message=f"lesson '{slug}' not found",
            frontend_message="That lesson doesn't exist.",
            details={"slug": slug},
        )


class ObservanceNotFoundError(NotFoundError):
    """Raised when no :class:`Observance` matches the requested slug."""

    def __init__(self, slug: str):
        super().__init__(
            message=f"observance '{slug}' not found",
            frontend_message="That observance doesn't exist.",
            details={"slug": slug},
        )


class PersonNotFoundError(NotFoundError):
    """Raised when no :class:`Person` matches the requested slug."""

    def __init__(self, slug: str):
        super().__init__(
            message=f"person '{slug}' not found",
            frontend_message="That person doesn't exist.",
            details={"slug": slug},
        )


# --- Auth + bookmarks -------------------------------------------------------


class EmailAlreadyRegisteredError(BaseError):
    """Raised when signup hits a duplicate email."""

    def __init__(self, email: str):
        super().__init__(
            message=f"email '{email}' is already registered",
            frontend_message="That email is already registered.",
            status_code=status.HTTP_409_CONFLICT,
            details={"email": email},
        )


class InvalidCredentialsError(BaseError):
    """Raised on login when email or password don't match."""

    def __init__(self):
        super().__init__(
            message="invalid email or password",
            frontend_message="That email and password don't match.",
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class InvalidTokenError(BaseError):
    """Raised when an access or refresh token is missing, malformed, or expired."""

    def __init__(self, reason: str = "invalid or expired token"):
        super().__init__(
            message=reason,
            frontend_message="Your session expired. Please sign in again.",
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class BookmarkTargetNotFoundError(NotFoundError):
    """Raised when the bookmarked slug points at no real resource."""

    def __init__(self, kind: str, slug: str):
        super().__init__(
            message=f"{kind} '{slug}' not found",
            frontend_message="That entry doesn't exist any more.",
            details={"kind": kind, "slug": slug},
        )


class BookmarkNotFoundError(NotFoundError):
    """Raised when deleting a bookmark that isn't there."""

    def __init__(self):
        super().__init__(
            message="bookmark not found",
            frontend_message="That bookmark doesn't exist.",
        )


class InvalidPasswordResetTokenError(BaseError):
    """Raised when the password reset token is unknown, expired, or already used."""

    def __init__(self, reason: str = "invalid or expired reset token"):
        super().__init__(
            message=reason,
            frontend_message="That reset link is no longer valid. Please request a new one.",
            status_code=status.HTTP_400_BAD_REQUEST,
        )
