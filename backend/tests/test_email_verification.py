"""End-to-end tests for the email-verification flow.

Same monkeypatched send-stub as test_password_reset.py so the suite stays
offline. Signup itself fires a verification email; we read the issued
token straight out of the DB rather than parsing the captured payload.
"""

from collections.abc import AsyncIterator
from uuid import uuid4

import pytest
from httpx import AsyncClient
from sqlalchemy import delete, select

from thaqafa import database as _database  # noqa: PLC2701 — test-only access to _session_factory
from thaqafa.api.services import email as email_service
from thaqafa.models.user import Bookmark, EmailVerificationToken, PasswordResetToken, User


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
async def fresh_email() -> AsyncIterator[str]:
    email = _unique_email("verify")
    yield email
    await _wipe_user(email)


@pytest.mark.asyncio
async def test_signup_creates_verification_token_and_unverified_user(client: AsyncClient, fresh_email: str):
    r = await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["user"]["emailVerified"] is False

    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u_row = (await s.exec(select(User).where(User.email == fresh_email))).first()
        assert u_row is not None
        user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
        tokens = (await s.exec(select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id))).all()
    assert len(tokens) == 1


@pytest.mark.asyncio
async def test_verify_email_with_valid_token_marks_user_verified(client: AsyncClient, fresh_email: str):
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )

    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u_row = (await s.exec(select(User).where(User.email == fresh_email))).first()
        user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
        token_row = (
            await s.exec(select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id))
        ).first()
    token = token_row[0] if hasattr(token_row, "_fields") or isinstance(token_row, tuple) else token_row

    r = await client.post("/api/v1/auth/email/verify", json={"token": token.token})
    assert r.status_code == 204

    # /me reflects the new flag for the same access token issued at signup.
    login = await client.post("/api/v1/auth/login", json={"email": fresh_email, "password": "correct-horse-battery"})
    access = login.json()["accessToken"]
    me = await client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {access}"})
    assert me.json()["emailVerified"] is True


@pytest.mark.asyncio
async def test_verify_email_rejects_unknown_token(client: AsyncClient):
    r = await client.post("/api/v1/auth/email/verify", json={"token": "x" * 32})
    assert r.status_code == 400
    assert r.json()["error"] == "InvalidEmailVerificationTokenError"


@pytest.mark.asyncio
async def test_verify_email_rejects_reused_token(client: AsyncClient, fresh_email: str):
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u_row = (await s.exec(select(User).where(User.email == fresh_email))).first()
        user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
        token_row = (
            await s.exec(select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id))
        ).first()
    token = token_row[0] if hasattr(token_row, "_fields") or isinstance(token_row, tuple) else token_row

    first = await client.post("/api/v1/auth/email/verify", json={"token": token.token})
    assert first.status_code == 204
    second = await client.post("/api/v1/auth/email/verify", json={"token": token.token})
    assert second.status_code == 400


@pytest.mark.asyncio
async def test_resend_unknown_email_returns_204(client: AsyncClient):
    r = await client.post("/api/v1/auth/email/resend", json={"email": "ghost@example.com"})
    assert r.status_code == 204


@pytest.mark.asyncio
async def test_resend_for_known_user_creates_new_token(client: AsyncClient, fresh_email: str):
    await client.post(
        "/api/v1/auth/signup",
        json={"email": fresh_email, "password": "correct-horse-battery", "displayName": "Test User"},
    )
    r = await client.post("/api/v1/auth/email/resend", json={"email": fresh_email})
    assert r.status_code == 204

    assert _database._session_factory is not None
    async with _database._session_factory() as s:
        u_row = (await s.exec(select(User).where(User.email == fresh_email))).first()
        user = u_row[0] if hasattr(u_row, "_fields") or isinstance(u_row, tuple) else u_row
        tokens = (await s.exec(select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id))).all()
    # One from signup + one from resend.
    assert len(tokens) == 2
