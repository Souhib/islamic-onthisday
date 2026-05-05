"""Event detail endpoint tests against the real pipeline DB."""

import pytest


@pytest.mark.asyncio
async def test_event_by_slug_returns_detail(client):
    """A known curated slug returns a populated EventDetail (camelCase keys)."""
    r = await client.get("/api/v1/events/fall-of-granada")
    assert r.status_code == 200
    data = r.json()
    # camelCase aliasing is in effect
    assert data["title"]
    # Canonical snake_case discriminant aliased to camelCase on the wire.
    assert data["verificationStatus"] in {
        "scholar_reviewed",
        "cross_verified",
        "single_source",
        "unverified",
    }
    assert "noImage" in data
    assert "disputedPositions" in data
    assert isinstance(data["sources"], list)


@pytest.mark.asyncio
async def test_event_unknown_slug_returns_404(client):
    """A bogus slug yields 404 with a useful detail message."""
    r = await client.get("/api/v1/events/no-such-event-here-please")
    assert r.status_code == 404
    body = r.json()
    assert body["error"] == "EventNotFoundError"
    assert body["error_key"] == "errors.api.eventNotFound"
    assert body["details"]["slug"] == "no-such-event-here-please"


@pytest.mark.asyncio
async def test_event_invalid_slug_rejected(client):
    """Slugs with disallowed characters fail validation upstream of the controller."""
    r = await client.get("/api/v1/events/Bad Slug!")
    assert r.status_code == 422
