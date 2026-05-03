"""Coverage for the list / search / observances / people endpoints."""

import pytest


@pytest.mark.asyncio
async def test_event_list_default(client):
    """``/api/v1/events`` returns a paginated list with totals."""
    r = await client.get("/api/v1/events", params={"limit": 5})
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data["items"], list)
    assert len(data["items"]) <= 5
    assert data["limit"] == 5
    assert data["offset"] == 0
    assert data["total"] >= len(data["items"])
    if data["items"]:
        first = data["items"][0]
        assert "verificationStatus" in first
        assert "title" in first


@pytest.mark.asyncio
async def test_event_list_filter_by_importance(client):
    """The ``importance=major`` filter narrows the result set."""
    r = await client.get("/api/v1/events", params={"importance": "major", "limit": 50})
    assert r.status_code == 200
    data = r.json()
    for item in data["items"]:
        assert item["importance"] == "major"


@pytest.mark.asyncio
async def test_event_search_by_q(client):
    """Substring ``q`` matches at least one curated event by title."""
    r = await client.get("/api/v1/events", params={"q": "granada", "limit": 10})
    assert r.status_code == 200
    data = r.json()
    titles = " ".join(i["title"].lower() for i in data["items"])
    assert "granada" in titles


@pytest.mark.asyncio
async def test_observance_list_orders_by_hijri_calendar(client):
    """``/api/v1/observances`` returns rows ordered by Hijri month + day."""
    r = await client.get("/api/v1/observances")
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    months = [o["hijriMonth"] for o in data]
    assert months == sorted(months)
    # Trilingual contract: descriptionEn is required, _ar/_fr optional.
    assert all("descriptionEn" in o for o in data)


@pytest.mark.asyncio
async def test_observance_by_slug(client):
    """A known observance slug returns the matched detail."""
    list_r = await client.get("/api/v1/observances")
    slugs = [o["id"] for o in list_r.json()]
    assert slugs, "the observances table is empty in the test DB"
    r = await client.get(f"/api/v1/observances/{slugs[0]}")
    assert r.status_code == 200
    body = r.json()
    assert body["id"] == slugs[0]


@pytest.mark.asyncio
async def test_person_404(client):
    """Bogus slug yields 404."""
    r = await client.get("/api/v1/people/no-such-person-here")
    assert r.status_code == 404
