"""Auth request and response schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import EmailStr, Field

from iotd.api.schemas.shared import RequestModel, ResponseModel


class SignupRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/signup``."""

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    display_name: str | None = Field(default=None, max_length=64)


class LoginRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/login``."""

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshRequest(RequestModel):
    """Inputs for ``POST /api/v1/auth/refresh``."""

    refresh_token: str


class UserPublic(ResponseModel):
    """Public account view — never includes the password hash."""

    id: UUID
    email: EmailStr
    display_name: str | None
    created_at: datetime


class TokenPair(ResponseModel):
    """Issued on signup, login, and refresh."""

    access_token: str
    refresh_token: str
    access_expires_at: datetime
    refresh_expires_at: datetime
    user: UserPublic
