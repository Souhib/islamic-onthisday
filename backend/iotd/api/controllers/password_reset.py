"""Password reset controller — email-driven, token-based.

Two endpoints:

- ``POST /auth/password-reset/request`` — accepts an email, mints a
  short-lived token, sends a Resend email with a link the FE handles.
  Always returns 204 regardless of whether the email is registered, so
  account-existence isn't leaked to a probe.
- ``POST /auth/password-reset/confirm`` — accepts the token + a new
  password, verifies the token (exists, not expired, not already used),
  rotates the password hash, and marks the token used.
"""

import secrets
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import InvalidPasswordResetTokenError
from iotd.api.schemas.auth import PasswordResetConfirm, PasswordResetRequest
from iotd.api.services.auth import hash_password
from iotd.api.services.email import send_email
from iotd.api.services.email_templates import password_reset_email
from iotd.models.user import PasswordResetToken, User
from iotd.settings import Settings


class PasswordResetController:
    """Issues and consumes password-reset tokens."""

    def __init__(self, session: AsyncSession, settings: Settings):
        self.session = session
        self.settings = settings

    async def request_reset(self, body: PasswordResetRequest) -> None:
        """Mint a token + send the email. Silent on unknown emails."""
        normalised = body.email.strip().lower()
        stmt = select(User).where(User.email == normalised)
        row = (await self.session.exec(stmt)).first()
        user: User | None = row[0] if row is not None else None
        if user is None or not user.is_active:
            return

        token_value = secrets.token_urlsafe(32)
        expires_at = datetime.now(UTC) + timedelta(minutes=self.settings.password_reset_token_minutes)
        record = PasswordResetToken(token=token_value, user_id=user.id, expires_at=expires_at)
        self.session.add(record)
        await self.session.commit()

        reset_url = f"{self.settings.frontend_url.rstrip('/')}/reset-password?token={token_value}"
        subject, html, text = password_reset_email(
            reset_url=reset_url,
            user_display_name=user.display_name,
        )
        send_email(to=user.email, subject=subject, html=html, text=text, settings=self.settings)

    async def confirm_reset(self, body: PasswordResetConfirm) -> None:
        """Validate the token, rotate the password, mark the token used."""
        record = await self.session.get(PasswordResetToken, body.token)
        if record is None or record.used_at is not None:
            raise InvalidPasswordResetTokenError()

        # SQLite drops the timezone on TIMESTAMP columns even with
        # ``TIMESTAMP(timezone=True)`` — we normalise to aware UTC before
        # comparing so the same code works on Postgres (aware) and SQLite
        # (naive that we treat as UTC by convention).
        expires_at = record.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=UTC)
        if expires_at <= datetime.now(UTC):
            raise InvalidPasswordResetTokenError("token expired")

        user = await self.session.get(User, record.user_id)
        if user is None or not user.is_active:
            raise InvalidPasswordResetTokenError("user no longer active")

        user.password_hash = hash_password(body.new_password)
        record.used_at = datetime.now(UTC)
        await self.session.commit()
