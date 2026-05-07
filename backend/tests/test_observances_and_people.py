"""Coverage for the observances + people endpoints.

The events resource is exposed only by slug (``/api/v1/events/{slug}``);
its tests live in ``test_events.py``. There is no list / search endpoint
by design — see ``thaqafa/api/routes/events.py`` for the rationale.
"""

import pytest


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
