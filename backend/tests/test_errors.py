"""Unit tests for ``iotd.api.errors``.

Covers:
- ``BaseError._generate_error_key`` derivations
- per-status auto-log level defaults
- ``log=False`` opt-out
- the typed per-resource subclasses surface the right defaults
"""

from typing import Any

from fastapi import status

from iotd.api.errors import (
    BaseError,
    EventNotFoundError,
    LessonNotFoundError,
    LogLevel,
    NotFoundError,
    ObservanceNotFoundError,
    PersonNotFoundError,
    ValidationError,
    _default_log_level,
)


class _SampleEventNotFoundError(BaseError):  # noqa: N801 — intentional CamelCase for the regex test
    """Used to assert error_key derivation from a multi-word camel name."""


class _IO(BaseError):  # noqa: N801, N818 — short class name to test the regex
    pass


def test_generate_error_key_strips_trailing_error() -> None:
    """``EventNotFoundError`` → ``errors.api.eventNotFound``."""
    assert EventNotFoundError._generate_error_key() == "errors.api.eventNotFound"
    assert LessonNotFoundError._generate_error_key() == "errors.api.lessonNotFound"
    assert ObservanceNotFoundError._generate_error_key() == "errors.api.observanceNotFound"
    assert PersonNotFoundError._generate_error_key() == "errors.api.personNotFound"


def test_generate_error_key_handles_acronyms_and_short_names() -> None:
    """Pure CamelCase and acronym-style class names produce stable keys."""
    assert _SampleEventNotFoundError._generate_error_key() == "errors.api.sampleEventNotFound"
    assert _IO._generate_error_key() == "errors.api.iO"  # lowercase head + UpperCase tail


def test_default_log_level_per_status_code() -> None:
    """5xx → ERROR, 401/403/409 → WARNING, other 4xx → DEBUG."""
    assert _default_log_level(500) is LogLevel.ERROR
    assert _default_log_level(503) is LogLevel.ERROR
    assert _default_log_level(401) is LogLevel.WARNING
    assert _default_log_level(403) is LogLevel.WARNING
    assert _default_log_level(409) is LogLevel.WARNING
    assert _default_log_level(404) is LogLevel.DEBUG
    assert _default_log_level(400) is LogLevel.DEBUG
    assert _default_log_level(422) is LogLevel.DEBUG


def test_baseerror_logs_at_default_level_unless_overridden(monkeypatch) -> None:
    """``BaseError.__init__`` calls the loguru function for its computed level.

    Patches the ``_LOG_FUNCTIONS`` map so we can assert which one was hit.
    """
    calls: dict[str, list[Any]] = {"DEBUG": [], "WARNING": [], "ERROR": []}
    fake_map = {
        LogLevel.DEBUG: lambda *a, **kw: calls["DEBUG"].append((a, kw)),
        LogLevel.INFO: lambda *a, **kw: calls.setdefault("INFO", []).append((a, kw)),
        LogLevel.WARNING: lambda *a, **kw: calls["WARNING"].append((a, kw)),
        LogLevel.ERROR: lambda *a, **kw: calls["ERROR"].append((a, kw)),
        LogLevel.CRITICAL: lambda *a, **kw: calls.setdefault("CRITICAL", []).append((a, kw)),
    }
    monkeypatch.setattr("iotd.api.errors._LOG_FUNCTIONS", fake_map)

    BaseError("boom-500")
    BaseError("boom-401", status_code=401)
    BaseError("boom-404", status_code=404)
    assert len(calls["ERROR"]) == 1, "5xx should log at ERROR"
    assert len(calls["WARNING"]) == 1, "401 should log at WARNING"
    assert len(calls["DEBUG"]) == 1, "404 should log at DEBUG"


def test_baseerror_log_false_suppresses_the_phantom_line(monkeypatch) -> None:
    """``log=False`` is the escape hatch for try/except sites."""
    calls: list[tuple] = []
    monkeypatch.setattr(
        "iotd.api.errors._LOG_FUNCTIONS",
        {level: lambda *a, **kw: calls.append((a, kw)) for level in LogLevel},
    )
    BaseError("silent", log=False)
    assert calls == []


def test_typed_subclasses_carry_status_404_and_slug_in_details() -> None:
    """The typed errors are 404 with the slug surfaced in ``details``."""
    for cls in (EventNotFoundError, LessonNotFoundError, ObservanceNotFoundError, PersonNotFoundError):
        err = cls("foo-bar")
        assert err.status_code == status.HTTP_404_NOT_FOUND
        assert err.details == {"slug": "foo-bar"}
        assert err.frontend_message  # always populated
        assert err.error_key.startswith("errors.api.")


def test_notfound_error_default_status_code() -> None:
    """``NotFoundError`` defaults to 404 even when no kwarg is passed."""
    err = NotFoundError("not here")
    assert err.status_code == status.HTTP_404_NOT_FOUND


def test_validation_error_default_status_code() -> None:
    """``ValidationError`` defaults to 422."""
    err = ValidationError("bad")
    assert err.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
