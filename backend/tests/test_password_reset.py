"""End-to-end tests for the password reset flow.

The Resend send call is monkeypatched to a no-op so the suite stays
offline. We capture the issued token from the DB rather than parsing it
out of an email body.
"""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest
from httpx import AsyncClient
from sqlalchemy import delete, select

from thaqafa import database as _database  # noqa: PLC2701 — test-only access to _session_factory
from thaqafa.api.services import email as email_service
from thaqafa.models.user import Bookmark, PasswordResetToken, User


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
        await session.exec(delete(User).where(User.id == user_id))  # type: ignore[call-overload]
        await session.commit()


@pytest.fixture(autouse=True)
def _stub_email_send(monkeypatch: pytest.MonkeyPatch):
    """No real Resend calls during the suite."""
    sent: list[dict] = []

    def _capture(payload: dict) -> dict:
        sent.append(payload)
        return {"id": "stub"}

    monkeypatch.setattr(email_service, "_resolve_send", lambda: _capture)
    return sent


@pytest.fixture
async def fresh_email() -> AsyncIterator[str]:
    email = _unique_email("pwreset")
    yield email
    await _wipe_user(email)


@pytest.mark.asyncio
async def test_request_reset_unknown_email_silently_returns_204(client: AsyncClient):
    r = await client.post(
        "/api/v1/auth/password-reset/request",
        json={"email": "nobody-knows@example.com"},
    )
    assert r.status_code == 204


@pytest.mark.asyncio
async def test_request_reset_creates_token_for_known_user(
    client: AsyncClient, fresh_email: str, monkeypatch: pytest.MonkeyPatch
):
    # Make Resend appear configured so the email path executes (the stub
    # captures payloads instead of making a real call).
    from thaqafa.settings import get_settings  # noqa: PLC0415 — test wiring

    original = get_settings()

    def _settings_with_key():
        original.resend_api_key = "re_test_stub"
        return original

    monkeypatch.setattr("thaqafa.dependencies.get_active_settings", _settings_with_key)

    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    r = await client.post(
        "/api/v1/auth/password-reset/request",
        json={"email": fresh_email},
    )
    assert r.status_code == 204

    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u = (await s.exec(select(User).where(User.email == fresh_email))).first()
        assert u is not None
        user_id = u[0].id
        tokens = (await s.exec(select(PasswordResetToken).where(PasswordResetToken.user_id == user_id))).all()
    assert len(tokens) == 1


@pytest.mark.asyncio
async def test_confirm_reset_with_valid_token_rotates_password(client: AsyncClient, fresh_email: str):
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    await client.post("/api/v1/auth/password-reset/request", json={"email": fresh_email})

    # Pull the token straight out of the DB rather than parsing the email.
    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u = (await s.exec(select(User).where(User.email == fresh_email))).first()
        assert u is not None
        token = (await s.exec(select(PasswordResetToken).where(PasswordResetToken.user_id == u[0].id))).first()
    assert token is not None
    token_value = token[0].token

    # Confirm with new password
    r = await client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": token_value, "newPassword": "fresh-pass-9876"},
    )
    assert r.status_code == 204

    # Login with old password fails, new password succeeds
    bad = await client.post("/api/v1/auth/login", json={"email": fresh_email, "password": "correct-horse-battery"})
    assert bad.status_code == 401
    ok = await client.post("/api/v1/auth/login", json={"email": fresh_email, "password": "fresh-pass-9876"})
    assert ok.status_code == 200


@pytest.mark.asyncio
async def test_confirm_reset_rejects_unknown_token(client: AsyncClient):
    r = await client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": "x" * 32, "newPassword": "fresh-pass-9876"},
    )
    assert r.status_code == 400
    assert r.json()["error"] == "InvalidPasswordResetTokenError"


@pytest.mark.asyncio
async def test_confirm_reset_rejects_reused_token(client: AsyncClient, fresh_email: str):
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    await client.post("/api/v1/auth/password-reset/request", json={"email": fresh_email})

    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u = (await s.exec(select(User).where(User.email == fresh_email))).first()
        assert u is not None
        token = (await s.exec(select(PasswordResetToken).where(PasswordResetToken.user_id == u[0].id))).first()
    token_value = token[0].token  # type: ignore[index]

    first = await client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": token_value, "newPassword": "fresh-pass-9876"},
    )
    assert first.status_code == 204

    second = await client.post(
        "/api/v1/auth/password-reset/confirm",
        json={"token": token_value, "newPassword": "another-pass-1234"},
    )
    assert second.status_code == 400
