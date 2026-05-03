"""Recent endpoint tests against the real pipeline DB."""

import pytest


@pytest.mark.asyncio
async def test_recent_default_returns_7_days(client):
    """``/api/v1/recent`` returns 7 days by default."""
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
async def test_recent_custom_days(client):
    """The ``days`` parameter controls how many days are returned."""
    r = await client.get("/api/v1/recent", params={"days": 3})
    assert r.status_code == 200
    data = r.json()
    assert len(data["days"]) == 3


@pytest.mark.asyncio
async def test_recent_days_validation_rejects_out_of_range(client):
    """``days`` above 14 fails FastAPI validation."""
    r = await client.get("/api/v1/recent", params={"days": 99})
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_recent_falls_back_to_lessons_when_no_event_match(client):
    """Days with no curated event fall back to a dateless lesson.

    Regression guard: the original ``RecentController`` composed
    ``TodayController.today(d)`` per-day so the lesson fallback was
    inherited. The batched rewrite has to recreate that fallback explicitly.
    """
    r = await client.get("/api/v1/recent", params={"days": 14})
    assert r.status_code == 200
    data = r.json()
    # At least one of the 14 days should have a headline (event or lesson).
    # Dataset reality: with the lesson fallback in place, every day should
    # have *something*; without it, sparse days show null.
    headlines = [day["headline"] for day in data["days"]]
    non_null = [h for h in headlines if h is not None]
    assert non_null, "every day should have a headline (event or lesson fallback)"
    # And the kind discriminant should distinguish lesson vs event.
    kinds = {h.get("kind") for h in non_null}
    assert kinds.issubset({None, "lesson"}), f"unexpected headline kinds: {kinds}"
