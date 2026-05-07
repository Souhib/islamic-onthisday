"""Health endpoint smoke tests."""

import pytest


@pytest.mark.asyncio
async def test_health_returns_ok_with_dataset_snapshot(client):
    """``/health`` returns 200 with the dataset snapshot when DB is up."""
    r = await client.get("/api/v1/health")
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "ok"
    assert data["database"] == "ok"
    assert data["version"]

    # New: dataset snapshot is an ops signal — counts + freshness.
    snapshot = data["dataset"]
    assert snapshot is not None
    assert isinstance(snapshot["eventCount"], int)
    assert isinstance(snapshot["lessonCount"], int)
    assert isinstance(snapshot["observanceCount"], int)
    assert isinstance(snapshot["personCount"], int)
    # builtAt + ageHours are populated when there's at least one event.
    if snapshot["eventCount"] > 0:
        assert snapshot["builtAt"] is not None
        assert isinstance(snapshot["ageHours"], int | float)


@pytest.mark.asyncio
async def test_health_is_no_store(client):
    """Health must never be cached — masking an outage is worse than the cost."""
    r = await client.get("/api/v1/health")
    assert r.headers.get("Cache-Control") == "no-store"
