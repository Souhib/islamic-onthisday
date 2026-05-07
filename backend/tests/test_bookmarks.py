"""End-to-end tests for the bookmarks surface."""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest
from httpx import AsyncClient
from sqlalchemy import delete, select

from thaqafa import database as _database  # noqa: PLC2701 — test-only access to _session_factory
from thaqafa.models.user import Bookmark, User


def _unique_email(tag: str) -> str:
    return f"test-{tag}-{uuid4().hex[:8]}@example.com"


async def _wipe_user(email: str) -> None:
    if _database._session_factory is None:
        return
    async with _database._session_factory() as session:
        result = (await session.exec(select(User).where(User.email == email))).first()
        if result is None:
            return
        user = result[0] if hasattr(result, "_fields") or isinstance(result, tuple) else result
        user_id = user.id
        await session.exec(delete(Bookmark).where(Bookmark.user_id == user_id))  # type: ignore[call-overload]
        await session.exec(delete(User).where(User.id == user_id))  # type: ignore[call-overload]
        await session.commit()


@pytest.fixture
async def auth_user(client: AsyncClient) -> AsyncIterator[tuple[str, dict[str, str]]]:
    """Sign up a unique account and yield ``(email, auth-headers)``."""
    email = _unique_email("bm")
    r = await client.post(
        "/api/v1/auth/signup", json={"email": email, "password": "correct-horse-battery", "displayName": "Test User"}
    )
    assert r.status_code == 201
    headers = {"Authorization": f"Bearer {r.json()['accessToken']}"}
    yield email, headers
    await _wipe_user(email)


@pytest.mark.asyncio
async def test_list_empty_for_new_user(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    r = await client.get("/api/v1/bookmarks", headers=headers)
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == 0
    assert body["items"] == []


@pytest.mark.asyncio
async def test_create_and_list_bookmark_for_known_event(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    create = await client.post(
        "/api/v1/bookmarks",
        headers=headers,
        json={"targetKind": "event", "targetSlug": "fall-of-granada"},
    )
    assert create.status_code == 201
    body = create.json()
    assert body["targetKind"] == "event"
    assert body["targetSlug"] == "fall-of-granada"
    assert body["targetTitle"]  # event has an EN title

    listed = await client.get("/api/v1/bookmarks", headers=headers)
    assert listed.status_code == 200
    items = listed.json()["items"]
    assert len(items) == 1
    assert items[0]["id"] == body["id"]


@pytest.mark.asyncio
async def test_create_bookmark_idempotent_on_duplicate(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    payload = {"targetKind": "event", "targetSlug": "fall-of-granada"}
    first = await client.post("/api/v1/bookmarks", headers=headers, json=payload)
    second = await client.post("/api/v1/bookmarks", headers=headers, json=payload)
    assert first.status_code == 201
    assert second.status_code == 201
    assert first.json()["id"] == second.json()["id"]


@pytest.mark.asyncio
async def test_create_bookmark_unknown_slug_returns_404(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    r = await client.post(
        "/api/v1/bookmarks",
        headers=headers,
        json={"targetKind": "event", "targetSlug": "no-such-event-here-please"},
    )
    assert r.status_code == 404
    assert r.json()["error"] == "BookmarkTargetNotFoundError"


@pytest.mark.asyncio
async def test_delete_bookmark(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    create = await client.post(
        "/api/v1/bookmarks",
        headers=headers,
        json={"targetKind": "event", "targetSlug": "fall-of-granada"},
    )
    bookmark_id = create.json()["id"]

    deleted = await client.delete(f"/api/v1/bookmarks/{bookmark_id}", headers=headers)
    assert deleted.status_code == 204

    listed = await client.get("/api/v1/bookmarks", headers=headers)
    assert listed.json()["total"] == 0


@pytest.mark.asyncio
async def test_delete_unknown_bookmark_returns_404(client: AsyncClient, auth_user: tuple[str, dict[str, str]]):
    _, headers = auth_user
    r = await client.delete(f"/api/v1/bookmarks/{uuid4()}", headers=headers)
    assert r.status_code == 404


@pytest.mark.asyncio
async def test_bookmarks_require_authentication(client: AsyncClient):
    r = await client.get("/api/v1/bookmarks")
    assert r.status_code == 401


@pytest.mark.asyncio
async def test_users_cannot_see_each_others_bookmarks(client: AsyncClient):
    email_a = _unique_email("bma")
    email_b = _unique_email("bmb")
    try:
        ra = await client.post(
            "/api/v1/auth/signup",
            json={"email": email_a, "password": "correct-horse-battery", "displayName": "Test User"},
        )
        rb = await client.post(
            "/api/v1/auth/signup",
            json={"email": email_b, "password": "correct-horse-battery", "displayName": "Test User"},
        )
        ha = {"Authorization": f"Bearer {ra.json()['accessToken']}"}
        hb = {"Authorization": f"Bearer {rb.json()['accessToken']}"}

        await client.post(
            "/api/v1/bookmarks", headers=ha, json={"targetKind": "event", "targetSlug": "fall-of-granada"}
        )
        b_list = await client.get("/api/v1/bookmarks", headers=hb)
        assert b_list.json()["total"] == 0
    finally:
        await _wipe_user(email_a)
        await _wipe_user(email_b)
