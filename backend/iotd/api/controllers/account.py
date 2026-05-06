"""Account self-management — display name, password, email."""

import secrets
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.errors import (
    EmailAlreadyRegisteredError,
    InvalidEmailChangeTokenError,
    WrongCurrentPasswordError,
)
from iotd.api.schemas.auth import (
    ChangeDisplayNameRequest,
    ChangeEmailConfirm,
    ChangeEmailRequest,
    ChangePasswordRequest,
)
from iotd.api.services.auth import hash_password, verify_password
from iotd.api.services.email import send_email
from iotd.api.services.email_templates import (
    email_change_notice_email,
    email_change_verify_email,
    password_changed_email,
)
from iotd.models.user import EmailChangeToken, User
from iotd.settings import Settings


class AccountController:
    """Owns the per-user mutations off /api/v1/auth/me/*."""

    def __init__(self, session: AsyncSession, settings: Settings):
        self.session = session
        self.settings = settings

    async def change_display_name(self, user: User, body: ChangeDisplayNameRequest) -> User:
        """No verification — display name is cosmetic."""
        user.display_name = body.display_name
        await self.session.commit()
        await self.session.refresh(user)
        return user

    async def change_password(self, user: User, body: ChangePasswordRequest) -> None:
        """Verify the current password, rotate to the new hash, notify the user.

        We send the notification to the old (still-valid) email so a
        compromised session changing the password is at least visible.
        Reset link in the email points at the standard ``/forgot-password``
        flow so the legitimate owner can lock the attacker out.
        """
        if not verify_password(body.current_password, user.password_hash):
            raise WrongCurrentPasswordError()

        user.password_hash = hash_password(body.new_password)
        await self.session.commit()
        await self.session.refresh(user)

        reset_url = f"{self.settings.frontend_url.rstrip('/')}/forgot-password"
        subject, html, text = password_changed_email(
            reset_url=reset_url,
            user_display_name=user.display_name,
        )
        send_email(to=user.email, subject=subject, html=html, text=text, settings=self.settings)

    async def request_email_change(self, user: User, body: ChangeEmailRequest) -> None:
        """Mint an email-change token and send the verify link to the NEW email.

        The change is NOT applied yet — only on confirm. A heads-up goes
        to the old email so the user notices any unauthorised attempt.
        """
        if not verify_password(body.current_password, user.password_hash):
            raise WrongCurrentPasswordError()

        new_email = str(body.new_email).strip().lower()
        if new_email == user.email:
            return  # no-op silently — same address

        # Reject if the new email is already registered (other account).
        stmt = select(User).where(User.email == new_email)
        existing = (await self.session.exec(stmt)).first()
        if existing is not None:
            raise EmailAlreadyRegisteredError(new_email)

        token_value = secrets.token_urlsafe(32)
        expires_at = datetime.now(UTC) + timedelta(minutes=self.settings.password_reset_token_minutes)
        record = EmailChangeToken(
            token=token_value,
            user_id=user.id,
            new_email=new_email,
            expires_at=expires_at,
        )
        self.session.add(record)
        await self.session.commit()

        verify_url = f"{self.settings.frontend_url.rstrip('/')}/confirm-email-change?token={token_value}"
        subject, html, text = email_change_verify_email(
            verify_url=verify_url,
            user_display_name=user.display_name,
        )
        send_email(to=new_email, subject=subject, html=html, text=text, settings=self.settings)

        # Heads-up to old email so an unauthorised change is visible.
        reset_url = f"{self.settings.frontend_url.rstrip('/')}/forgot-password"
        n_subject, n_html, n_text = email_change_notice_email(
            reset_url=reset_url,
            new_email=new_email,
            user_display_name=user.display_name,
        )
        send_email(to=user.email, subject=n_subject, html=n_html, text=n_text, settings=self.settings)

    async def confirm_email_change(self, body: ChangeEmailConfirm) -> User:
        """Validate the token and swap ``user.email`` to the pending value.

        The user does NOT need to be authenticated — the token IS the
        proof of ownership of the new email. Returns the updated user
        so the caller can confirm the new address back to the FE.
        """
        record = await self.session.get(EmailChangeToken, body.token)
        if record is None or record.used_at is not None:
            raise InvalidEmailChangeTokenError()

        expires_at = record.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=UTC)
        if expires_at <= datetime.now(UTC):
            raise InvalidEmailChangeTokenError("token expired")

        user = await self.session.get(User, record.user_id)
        if user is None or not user.is_active:
            raise InvalidEmailChangeTokenError("user no longer active")

        # Final guard against a race: the new email may have been claimed
        # since the request was made.
        stmt = select(User).where(User.email == record.new_email, User.id != user.id)
        clash = (await self.session.exec(stmt)).first()
        if clash is not None:
            raise EmailAlreadyRegisteredError(record.new_email)

        user.email = record.new_email
        user.email_verified = True
        user.email_verified_at = datetime.now(UTC)
        record.used_at = datetime.now(UTC)
        try:
            await self.session.commit()
        except IntegrityError as e:
            await self.session.rollback()
            raise EmailAlreadyRegisteredError(record.new_email) from e
        await self.session.refresh(user)
        return user
