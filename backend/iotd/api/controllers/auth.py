"""Auth controller — signup, login, token refresh, current-user lookup."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlmodel.ext.asyncio.session import AsyncSession

from iotd.api.controllers.email_verification import EmailVerificationController
from iotd.api.errors import EmailAlreadyRegisteredError, InvalidCredentialsError, InvalidTokenError
from iotd.api.schemas.auth import LoginRequest, SignupRequest, TokenPair, UserPublic
from iotd.api.services.auth import (
    decode_token,
    hash_password,
    issue_access_token,
    issue_refresh_token,
    needs_rehash,
    verify_password,
)
from iotd.models.user import User
from iotd.settings import Settings


class AuthController:
    """Owns the account / session lifecycle."""

    def __init__(self, session: AsyncSession, settings: Settings):
        self.session = session
        self.settings = settings

    async def signup(self, body: SignupRequest) -> TokenPair:
        """Create a new account, kick off the verification email, and issue tokens."""
        normalised = body.email.strip().lower()
        user = User(
            email=normalised,
            password_hash=hash_password(body.password),
            display_name=body.display_name,
            email_verified=False,
        )
        self.session.add(user)
        try:
            await self.session.commit()
        except IntegrityError as e:
            await self.session.rollback()
            raise EmailAlreadyRegisteredError(normalised) from e
        await self.session.refresh(user)
        # Soft verification: the user is logged in immediately, the email
        # is best-effort. A failure here (Resend down, network blip)
        # surfaces as a 5xx — preferable to a silently-broken signup, and
        # the controller already commits the user before this call so the
        # account isn't lost.
        verifier = EmailVerificationController(self.session, self.settings)
        await verifier.send_for_user(user)
        return self._issue_pair(user)

    async def login(self, body: LoginRequest) -> TokenPair:
        """Verify credentials, update ``last_login_at``, and issue tokens."""
        normalised = body.email.strip().lower()
        stmt = select(User).where(User.email == normalised)
        row = (await self.session.exec(stmt)).first()
        user: User | None = row[0] if row is not None else None
        if user is None or not user.is_active or not verify_password(body.password, user.password_hash):
            raise InvalidCredentialsError()
        if needs_rehash(user.password_hash):
            user.password_hash = hash_password(body.password)
        user.last_login_at = datetime.now(UTC)
        await self.session.commit()
        await self.session.refresh(user)
        return self._issue_pair(user)

    async def refresh(self, refresh_token: str) -> TokenPair:
        """Exchange a valid refresh token for a fresh pair."""
        user_id = decode_token(refresh_token, expected_type="refresh", settings=self.settings)
        user = await self._get_active_user(user_id)
        return self._issue_pair(user)

    async def get_current_user(self, access_token: str) -> User:
        """Decode an access token and return the active user."""
        user_id = decode_token(access_token, expected_type="access", settings=self.settings)
        return await self._get_active_user(user_id)

    async def _get_active_user(self, user_id: UUID) -> User:
        user = await self.session.get(User, user_id)
        if user is None or not user.is_active:
            raise InvalidTokenError("user not found or inactive")
        return user

    def _issue_pair(self, user: User) -> TokenPair:
        access, access_exp = issue_access_token(user.id, self.settings)
        refresh, refresh_exp = issue_refresh_token(user.id, self.settings)
        return TokenPair(
            access_token=access,
            refresh_token=refresh,
            access_expires_at=access_exp,
            refresh_expires_at=refresh_exp,
            user=UserPublic.model_validate(user),
        )
