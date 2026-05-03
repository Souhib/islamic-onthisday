"""Lessons endpoint tests against the real pipeline DB."""

import pytest


@pytest.mark.asyncio
async def test_lesson_list_default(client):
    """``/api/v1/lessons`` returns a paginated list with totals."""
    r = await client.get("/api/v1/lessons", params={"limit": 5})
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data["items"], list)
    assert len(data["items"]) <= 5
    assert data["limit"] == 5
    assert data["offset"] == 0
    assert data["total"] >= len(data["items"])
    if data["items"]:
        first = data["items"][0]
        assert first["kind"] == "lesson"
        assert "title" in first


@pytest.mark.asyncio
async def test_lesson_list_filter_by_category(client):
    """The ``category`` filter narrows the result set."""
    r = await client.get("/api/v1/lessons", params={"category": "quran", "limit": 50})
    assert r.status_code == 200
    data = r.json()
    for item in data["items"]:
        assert item["category"] == "quran"


@pytest.mark.asyncio
async def test_lesson_by_slug(client):
    """A known lesson slug returns a populated LessonDetail."""
    list_r = await client.get("/api/v1/lessons", params={"limit": 1})
    slugs = [i["id"] for i in list_r.json()["items"]]
    assert slugs, "the lessons table is empty in the test DB"
    r = await client.get(f"/api/v1/lessons/{slugs[0]}")
    assert r.status_code == 200
    body = r.json()
    assert body["kind"] == "lesson"
    assert body["id"] == slugs[0]
    assert "body" in body


@pytest.mark.asyncio
async def test_lesson_unknown_slug_returns_404(client):
    """A bogus slug yields 404 with a useful message."""
    r = await client.get("/api/v1/lessons/no-such-lesson-here")
    assert r.status_code == 404
    body = r.json()
    assert body["error"] == "LessonNotFoundError"
    assert body["error_key"] == "errors.api.lessonNotFound"
    assert body["details"]["slug"] == "no-such-lesson-here"
