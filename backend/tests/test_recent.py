"""Recent endpoint tests against the real pipeline DB."""

import pytest


@pytest.mark.asyncio
async def test_recent_returns_seven_days(client):
    """``/api/v1/recent`` always returns exactly 7 calendar days.

    The width is fixed (``RECENT_WINDOW_DAYS=7``) — there is no ``?days=``
    knob by design. See CLAUDE.md rule 15.
    """
    r = await client.get("/api/v1/recent")
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data["days"], list)
    assert len(data["days"]) == 7
    first = data["days"][0]
    assert "date" in first
    assert "calendar" in first
    assert "headline" in first
    assert "observance" in first


@pytest.mark.asyncio
async def test_recent_ignores_unknown_query_params(client):
    """Stray query params (e.g. legacy ?days=14) are silently dropped — the
    endpoint takes no parameters now."""
    r = await client.get("/api/v1/recent", params={"days": 99})
    assert r.status_code == 200
    data = r.json()
    assert len(data["days"]) == 7


@pytest.mark.asyncio
async def test_recent_falls_back_to_lessons_when_no_event_match(client):
    """Days with no curated event fall back to a dateless lesson.

    Regression guard: every day in the catch-up window should carry
    *something* (event or lesson). The only way ``headline`` is null is
    when the dataset has neither — which would be a data-coverage bug.
    """
    r = await client.get("/api/v1/recent")
    assert r.status_code == 200
    data = r.json()
    headlines = [day["headline"] for day in data["days"]]
    non_null = [h for h in headlines if h is not None]
    assert non_null, "every day should have a headline (event or lesson fallback)"
    kinds = {h.get("kind") for h in non_null}
    assert kinds.issubset({None, "lesson"}), f"unexpected headline kinds: {kinds}"
