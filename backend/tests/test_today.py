"""Today endpoint smoke tests against the real pipeline DB."""

from datetime import UTC, datetime

import pytest


@pytest.mark.asyncio
async def test_today_calendar_present(client):
    """``/api/v1/today`` always returns the calendar slot, even on quiet days."""
    r = await client.get("/api/v1/today")
    assert r.status_code == 200
    data = r.json()
    assert "today" in data
    assert data["today"]["gregorian"]["year"] >= 2025
    assert 1 <= data["today"]["hijri"]["day"] <= 30
    # secondary may be empty on quiet days; the field still exists.
    assert isinstance(data["secondary"], list)


@pytest.mark.asyncio
async def test_today_does_not_accept_arbitrary_date(client):
    """The route deliberately exposes no `?on=` — daily-ritual constraint.

    Drilling into a specific historical day must go through `/events/{slug}`.
    """
    r = await client.get("/api/v1/today", params={"on": "1492-01-02"})
    # FastAPI silently drops unknown query params, so the request still
    # succeeds — just with today's content, not 1492's.
    assert r.status_code == 200
    data = r.json()
    today_year = datetime.now(UTC).year
    assert data["today"]["gregorian"]["year"] == today_year


@pytest.mark.asyncio
async def test_today_no_duplicate_slugs(client):
    """Headline and secondaries must never share a slug."""
    r = await client.get("/api/v1/today")
    assert r.status_code == 200
    data = r.json()

    slugs: set[str] = set()
    if data["headline"]:
        slugs.add(data["headline"]["id"])
    for item in data["secondary"]:
        assert item["id"] not in slugs, f"duplicate slug {item['id']}"
        slugs.add(item["id"])
