"""End-to-end tests for the auth surface.

The DB is shared with the read-only catalogue tests, so each test uses a
unique email and cleans up the row it inserted to keep runs idempotent.
"""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest
from httpx import AsyncClient
from sqlalchemy import delete, select

from iotd.database import _session_factory  # noqa: PLC2701 — test-only access
from iotd.models.user import Bookmark, User


def _unique_email(tag: str) -> str:
    return f"test-{tag}-{uuid4().hex[:8]}@example.com"


async def _wipe_user(email: str) -> None:
    if _session_factory is None:
        return
    async with _session_factory() as session:
        row = (await session.exec(select(User.id).where(User.email == email))).first()
        if row is None:
            return
        user_id = row[0] if isinstance(row, tuple) else row
        await session.exec(delete(Bookmark).where(Bookmark.user_id == user_id))  # type: ignore[call-overload]
        await session.exec(delete(User).where(User.id == user_id))  # type: ignore[call-overload]
        await session.commit()


@pytest.fixture
async def fresh_email() -> AsyncIterator[str]:
    email = _unique_email("auth")
    yield email
    await _wipe_user(email)


@pytest.mark.asyncio
async def test_signup_returns_token_pair_and_user(client: AsyncClient, fresh_email: str):
    r = await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["accessToken"]
    assert body["refreshToken"]
    assert body["accessExpiresAt"]
    assert body["user"]["email"] == fresh_email


@pytest.mark.asyncio
async def test_signup_duplicate_email_returns_409(client: AsyncClient, fresh_email: str):
    payload = {"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"}
    first = await client.post("/api/v1/auth/signup", json=payload)
    assert first.status_code == 201
    second = await client.post("/api/v1/auth/signup", json=payload)
    assert second.status_code == 409
    assert second.json()["error"] == "EmailAlreadyRegisteredError"


@pytest.mark.asyncio
async def test_signup_short_password_rejected(client: AsyncClient):
    r = await client.post("/api/v1/auth/signup", json={"email": "x@example.com", "password": "abc"})
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_login_round_trip(client: AsyncClient, fresh_email: str):
    password = "correct-horse-battery"
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": password, "displayName": "Test User"},
    )

    ok = await client.post("/api/v1/auth/login", json={"email": fresh_email, "password": password})
    assert ok.status_code == 200
    assert ok.json()["user"]["email"] == fresh_email

    bad = await client.post("/api/v1/auth/login", json={"email": fresh_email, "password": "wrong"})
    assert bad.status_code == 401
    assert bad.json()["error"] == "InvalidCredentialsError"


@pytest.mark.asyncio
async def test_signup_missing_display_name_rejected(client: AsyncClient):
    r = await client.post(
        "/api/v1/auth/signup",
        json={"email": "no-name@example.com", "password": "correct-horse-battery"},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_signup_whitespace_display_name_rejected(client: AsyncClient):
    r = await client.post(
        "/api/v1/auth/signup",
        json={"email": "blank-name@example.com", "password": "correct-horse-battery", "displayName": "   "},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_me_requires_bearer_token(client: AsyncClient):
    r = await client.get("/api/v1/auth/me")
    assert r.status_code == 401


@pytest.mark.asyncio
async def test_me_returns_profile_for_valid_token(client: AsyncClient, fresh_email: str):
    signup = await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    access = signup.json()["accessToken"]
    me = await client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {access}"})
    assert me.status_code == 200
    assert me.json()["email"] == fresh_email


@pytest.mark.asyncio
async def test_refresh_returns_new_pair(client: AsyncClient, fresh_email: str):
    signup = await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    refresh_token = signup.json()["refreshToken"]
    rotated = await client.post("/api/v1/auth/refresh", json={"refreshToken": refresh_token})
    assert rotated.status_code == 200
    assert rotated.json()["accessToken"] != signup.json()["accessToken"]


@pytest.mark.asyncio
async def test_refresh_rejects_access_token(client: AsyncClient, fresh_email: str):
    signup = await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    access = signup.json()["accessToken"]
    rotated = await client.post("/api/v1/auth/refresh", json={"refreshToken": access})
    assert rotated.status_code == 401
