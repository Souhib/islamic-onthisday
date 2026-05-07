"""Auth request and response schemas."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import EmailStr, Field, StringConstraints

from thaqafa.api.schemas.shared import RequestModel, ResponseModel

# Strip surrounding whitespace before applying length checks so a payload
# of "   " is rejected as missing rather than smuggled through as length-3.
_TrimmedDisplayName = Annotated[
    str,
    StringConstraints(strip_whitespace=True, min_length=1, max_length=64),
]


class SignupRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/signup``.

    ``display_name`` is required at the API boundary so every new account
    has a human label for the saves header (the ``User`` row keeps the
    column nullable so legacy / admin-created rows aren't forced to
    backfill).
    """

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    display_name: _TrimmedDisplayName


class LoginRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/login``."""

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/refresh``."""

    refresh_token: str


class PasswordResetRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/password-reset/request``."""

    email: EmailStr


class PasswordResetConfirm(RequestModel):
    """Inputs for ``POST /api/v1/auth/password-reset/confirm``."""

    token: str = Field(min_length=8, max_length=128)
    new_password: str = Field(min_length=8, max_length=128)


class EmailVerifyConfirm(RequestModel):
    """Inputs for ``POST /api/v1/auth/email/verify``."""

    token: str = Field(min_length=8, max_length=128)


class EmailVerifyResend(RequestModel):
    """Inputs for ``POST /api/v1/auth/email/resend``."""

    email: EmailStr


class ChangeDisplayNameRequest(RequestModel):
    """Inputs for ``PATCH /api/v1/auth/me``."""

    display_name: _TrimmedDisplayName


class ChangePasswordRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/me/password``."""

    current_password: str = Field(min_length=1, max_length=128)
    new_password: str = Field(min_length=8, max_length=128)


class ChangeEmailRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/me/email`` — starts the change flow.

    The password is required as a re-authentication step (the user is
    already logged in but we want a fresh proof-of-ownership before
    moving the email anywhere). The new email is the destination Resend
    sends the verification link to.
    """

    current_password: str = Field(min_length=1, max_length=128)
    new_email: EmailStr


class ChangeEmailConfirm(RequestModel):
    """Inputs for ``POST /api/v1/auth/me/email/confirm`` — completes the flow."""

    token: str = Field(min_length=8, max_length=128)


class UserPublic(ResponseModel):
    """Public account view — never includes the password hash."""

    id: UUID
    email: EmailStr
    display_name: str | None
    email_verified: bool
    created_at: datetime


class TokenPair(ResponseModel):
    """Issued on signup, login, and refresh."""

    access_token: str
    refresh_token: str
    access_expires_at: datetime
    refresh_expires_at: datetime
    user: UserPublic
