"""HTTP middleware tests — security headers, request id, query sanitisation."""

import pytest

from thaqafa.api.middleware import _sanitize_query_string, _sanitize_value


def test_sanitize_strips_script_tags() -> None:
    assert _sanitize_value("<script>alert(1)</script>hi") == "hi"


def test_sanitize_strips_event_handlers() -> None:
    """``onerror=`` etc. are common XSS vectors in URL params."""
    cleaned = _sanitize_value('onerror="x" image')
    assert "onerror=" not in cleaned


def test_sanitize_strips_dangerous_protocols() -> None:
    assert "javascript:" not in _sanitize_value("javascript:alert(1)")
    assert "vbscript:" not in _sanitize_value("vbscript:foo")
    assert "data:" not in _sanitize_value("data:text/html,<x>")


def test_sanitize_strips_path_traversal() -> None:
    assert "../" not in _sanitize_value("../../etc/passwd")


def test_sanitize_query_string_preserves_safe_input() -> None:
    """Plain query strings round-trip cleanly."""
    raw = "q=granada&limit=10"
    cleaned = _sanitize_query_string(raw)
    # ``urlencode`` may reorder pairs; just assert each survives.
    assert "q=granada" in cleaned
    assert "limit=10" in cleaned


def test_sanitize_query_string_handles_empty() -> None:
    assert _sanitize_query_string("") == ""


@pytest.mark.asyncio
async def test_security_headers_are_present_on_every_response(client) -> None:
    """``X-Content-Type-Options``, ``X-Frame-Options``, ``X-XSS-Protection``
    appear on every response.
    """
    r = await client.get("/api/v1/health")
    assert r.headers.get("x-content-type-options") == "nosniff"
    assert r.headers.get("x-frame-options") == "DENY"
    assert r.headers.get("x-xss-protection") == "1; mode=block"


@pytest.mark.asyncio
async def test_request_id_round_trips_when_provided(client) -> None:
    """A caller-supplied ``X-Request-ID`` is echoed back on the response."""
    r = await client.get("/api/v1/health", headers={"X-Request-ID": "trace-abc-123"})
    assert r.headers.get("x-request-id") == "trace-abc-123"


@pytest.mark.asyncio
async def test_request_id_is_generated_when_missing(client) -> None:
    """The middleware mints a fresh hex UUID when no inbound id is present."""
    r = await client.get("/api/v1/health")
    rid = r.headers.get("x-request-id")
    assert rid is not None
    assert len(rid) == 32  # UUID4 hex without dashes
