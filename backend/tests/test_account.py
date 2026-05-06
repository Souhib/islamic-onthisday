"""End-to-end tests for /auth/me/* — display name / password / email change."""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest
from httpx import AsyncClient
from sqlalchemy import delete, select

from iotd import database as _database  # noqa: PLC2701 — test-only access to _session_factory
from iotd.api.services import email as email_service
from iotd.models.user import (
    Bookmark,
    EmailChangeToken,
    EmailVerificationToken,
    PasswordResetToken,
    User,
)


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
        await session.exec(delete(PasswordResetToken).where(PasswordResetToken.user_id == user_id))  # type: ignore[call-overload]
        await session.exec(delete(EmailVerificationToken).where(EmailVerificationToken.user_id == user_id))  # type: ignore[call-overload]
        await session.exec(delete(EmailChangeToken).where(EmailChangeToken.user_id == user_id))  # type: ignore[call-overload]
        await session.exec(delete(User).where(User.id == user_id))  # type: ignore[call-overload]
        await session.commit()


@pytest.fixture(autouse=True)
def _stub_email_send(monkeypatch: pytest.MonkeyPatch):
    sent: list[dict] = []

    def _capture(payload: dict) -> dict:
        sent.append(payload)
        return {"id": "stub"}

    monkeypatch.setattr(email_service, "_resolve_send", lambda: _capture)
    return sent


@pytest.fixture
async def auth() -> AsyncIterator[tuple[str, str, dict[str, str]]]:
    """Sign up a user and yield ``(email, password, headers)``."""
    email = _unique_email("acct")
    password = "correct-horse-battery"
    yield email, password, {}
    await _wipe_user(email)


async def _signup(client: AsyncClient, email: str, password: str) -> dict[str, str]:
    r = await client.post(
        "/api/v1/auth/signup",
        json={"email": email, "password": password, "displayName": "Test User"},
    )
    assert r.status_code == 201
    return {"Authorization": f"Bearer {r.json()['accessToken']}"}


@pytest.mark.asyncio
async def test_change_display_name_persists(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    r = await client.patch("/api/v1/auth/me", headers=headers, json={"displayName": "New Name"})
    assert r.status_code == 200
    assert r.json()["displayName"] == "New Name"

    me = await client.get("/api/v1/auth/me", headers=headers)
    assert me.json()["displayName"] == "New Name"


@pytest.mark.asyncio
async def test_change_display_name_rejects_blank(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    r = await client.patch("/api/v1/auth/me", headers=headers, json={"displayName": "   "})
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_change_password_with_correct_current(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)

    r = await client.post(
        "/api/v1/auth/me/password",
        headers=headers,
        json={"currentPassword": password, "newPassword": "fresh-pass-9876"},
    )
    assert r.status_code == 204

    bad = await client.post("/api/v1/auth/login", json={"email": email, "password": password})
    assert bad.status_code == 401
    ok = await client.post("/api/v1/auth/login", json={"email": email, "password": "fresh-pass-9876"})
    assert ok.status_code == 200


@pytest.mark.asyncio
async def test_change_password_rejects_wrong_current(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)

    r = await client.post(
        "/api/v1/auth/me/password",
        headers=headers,
        json={"currentPassword": "totally-wrong", "newPassword": "fresh-pass-9876"},
    )
    assert r.status_code == 400
    assert r.json()["error"] == "WrongCurrentPasswordError"


@pytest.mark.asyncio
async def test_change_password_rejects_short_new(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    r = await client.post(
        "/api/v1/auth/me/password",
        headers=headers,
        json={"currentPassword": password, "newPassword": "tiny"},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_request_email_change_creates_token(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    new_email = _unique_email("acct-new")

    try:
        r = await client.post(
            "/api/v1/auth/me/email",
            headers=headers,
            json={"currentPassword": password, "newEmail": new_email},
        )
        assert r.status_code == 204

        # User row still has the OLD email.
        me = await client.get("/api/v1/auth/me", headers=headers)
        assert me.json()["email"] == email

        # A token row exists for this user with the new_email pending.
        assert _database._session_factory is not None
        async with _database._session_factory() as s:
            u_row = (await s.exec(select(User).where(User.email == email))).first()
            user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
            tokens = (await s.exec(select(EmailChangeToken).where(EmailChangeToken.user_id == user.id))).all()
            tokens_unwrapped = [t[0] if hasattr(t, "_fields") or isinstance(t, tuple) else t for t in tokens]
        assert len(tokens_unwrapped) == 1
        assert tokens_unwrapped[0].new_email == new_email
    finally:
        await _wipe_user(new_email)


@pytest.mark.asyncio
async def test_request_email_change_rejects_wrong_password(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    r = await client.post(
        "/api/v1/auth/me/email",
        headers=headers,
        json={"currentPassword": "wrong", "newEmail": _unique_email("acct-x")},
    )
    assert r.status_code == 400
    assert r.json()["error"] == "WrongCurrentPasswordError"


@pytest.mark.asyncio
async def test_request_email_change_rejects_taken(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)

    # Sign up another account whose email we'll try to claim.
    other = _unique_email("acct-other")
    await _signup(client, other, "correct-horse-battery")
    try:
        r = await client.post(
            "/api/v1/auth/me/email",
            headers=headers,
            json={"currentPassword": password, "newEmail": other},
        )
        assert r.status_code == 409
        assert r.json()["error"] == "EmailAlreadyRegisteredError"
    finally:
        await _wipe_user(other)


@pytest.mark.asyncio
async def test_confirm_email_change_swaps_email(client: AsyncClient, auth):
    email, password, _ = auth
    headers = await _signup(client, email, password)
    new_email = _unique_email("acct-target")
    try:
        await client.post(
            "/api/v1/auth/me/email",
            headers=headers,
            json={"currentPassword": password, "newEmail": new_email},
        )

        assert _database._session_factory is not None
        async with _database._session_factory() as s:
            u_row = (await s.exec(select(User).where(User.email == email))).first()
            user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
            t_row = (await s.exec(select(EmailChangeToken).where(EmailChangeToken.user_id == user.id))).first()
        token_value = t_row[0].token if hasattr(t_row, "_fields") or isinstance(t_row, tuple) else t_row.token

        r = await client.post("/api/v1/auth/me/email/confirm", json={"token": token_value})
        assert r.status_code == 200
        assert r.json()["email"] == new_email

        # Old login fails, new email works.
        old = await client.post("/api/v1/auth/login", json={"email": email, "password": password})
        assert old.status_code == 401
        new = await client.post("/api/v1/auth/login", json={"email": new_email, "password": password})
        assert new.status_code == 200
    finally:
        await _wipe_user(new_email)


@pytest.mark.asyncio
async def test_confirm_email_change_rejects_unknown_token(client: AsyncClient):
    r = await client.post("/api/v1/auth/me/email/confirm", json={"token": "x" * 32})
    assert r.status_code == 400
    assert r.json()["error"] == "InvalidEmailChangeTokenError"
