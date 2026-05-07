"""Email verification controller — soft-verify on signup + resend + confirm.

Soft means: a fresh signup is logged in immediately and can use the app
right away. The flag drives a "please verify your email" banner on the
saves page and unlocks any future feature that wants to gate on
confirmed ownership (daily digest, etc.).
"""

import secrets
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.errors import InvalidEmailVerificationTokenError
from thaqafa.api.schemas.auth import EmailVerifyResend
from thaqafa.api.services.email import send_email
from thaqafa.api.services.email_templates import email_verification_email
from thaqafa.models.user import EmailVerificationToken, User
from thaqafa.settings import Settings


class EmailVerificationController:
    """Mints, sends, and consumes email-verification tokens."""

    def __init__(self, session: AsyncSession, settings: Settings):
        self.session = session
        self.settings = settings

    async def send_for_user(self, user: User) -> None:
        """Mint a token and send the verification email.

        Called by ``AuthController.signup`` directly so a successful
        signup always kicks off the email; also called by ``resend`` for
        users who never received / lost the original mail.
        """
        if user.email_verified:
            return  # already done — silent no-op

        token_value = secrets.token_urlsafe(32)
        expires_at = datetime.now(UTC) + timedelta(hours=self.settings.email_verification_token_hours)
        record = EmailVerificationToken(token=token_value, user_id=user.id, expires_at=expires_at)
        self.session.add(record)
        await self.session.commit()

        verify_url = f"{self.settings.frontend_url.rstrip('/')}/verify-email?token={token_value}"
        subject, html, text = email_verification_email(
            verify_url=verify_url,
            user_display_name=user.display_name,
        )
        send_email(to=user.email, subject=subject, html=html, text=text, settings=self.settings)

    async def resend(self, body: EmailVerifyResend) -> None:
        """Look the user up by email and (re)send a verification email.

        Always returns without raising on unknown email so we don't leak
        account existence — same posture as the password-reset request.
        """
        normalised = body.email.strip().lower()
        stmt = select(User).where(User.email == normalised)
        row = (await self.session.exec(stmt)).first()
        if row is None:
            return
        user = row[0] if hasattr(row, "_fields") or isinstance(row, tuple) else row
        if not user.is_active:
            return
        await self.send_for_user(user)

    async def confirm(self, token: str) -> None:
        """Validate a verification token and flip the user's flag."""
        record = await self.session.get(EmailVerificationToken, token)
        if record is None or record.used_at is not None:
            raise InvalidEmailVerificationTokenError()

        expires_at = record.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=UTC)
        if expires_at <= datetime.now(UTC):
            raise InvalidEmailVerificationTokenError("token expired")

        user = await self.session.get(User, record.user_id)
        if user is None or not user.is_active:
            raise InvalidEmailVerificationTokenError("user no longer active")

        if not user.email_verified:
            user.email_verified = True
            user.email_verified_at = datetime.now(UTC)
        record.used_at = datetime.now(UTC)
        await self.session.commit()
