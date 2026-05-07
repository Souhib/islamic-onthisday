"""Authentication primitives — Argon2 password hashing and JWT issuance.

Pure helpers, no DB access. The auth controller calls into these to
verify a password during login and to mint / decode tokens. Argon2id is
used because it's the OWASP-recommended default and resistant to GPU /
ASIC attacks; PyJWT handles signing.
"""

from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID, uuid4

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

from thaqafa.api.errors import InvalidTokenError
from thaqafa.settings import Settings

_HASHER = PasswordHasher()


def hash_password(plain: str) -> str:
    """Hash ``plain`` with Argon2id and return the encoded digest."""
    return _HASHER.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    """Return True iff ``plain`` matches ``hashed``."""
    try:
        return _HASHER.verify(hashed, plain)
    except VerifyMismatchError:
        return False


def needs_rehash(hashed: str) -> bool:
    """Return True if ``hashed`` was made with old Argon2 parameters."""
    return _HASHER.check_needs_rehash(hashed)


# --- JWT --------------------------------------------------------------------


def _encode(
    *,
    subject: UUID,
    expires_at: datetime,
    token_type: str,
    settings: Settings,
) -> str:
    payload: dict[str, Any] = {
        "sub": str(subject),
        "exp": int(expires_at.timestamp()),
        "iat": int(datetime.now(UTC).timestamp()),
        "type": token_type,
        "jti": uuid4().hex,
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def issue_access_token(user_id: UUID, settings: Settings) -> tuple[str, datetime]:
    """Mint a short-lived access JWT. Returns ``(token, expires_at_utc)``."""
    expires = datetime.now(UTC) + timedelta(minutes=settings.access_token_minutes)
    return _encode(subject=user_id, expires_at=expires, token_type="access", settings=settings), expires


def issue_refresh_token(user_id: UUID, settings: Settings) -> tuple[str, datetime]:
    """Mint a long-lived refresh JWT. Returns ``(token, expires_at_utc)``."""
    expires = datetime.now(UTC) + timedelta(days=settings.refresh_token_days)
    return _encode(subject=user_id, expires_at=expires, token_type="refresh", settings=settings), expires


def decode_token(token: str, *, expected_type: str, settings: Settings) -> UUID:
    """Decode + verify ``token`` and return the user id (``sub``).

    Raises:
        InvalidTokenError: when the token is malformed, expired, or of
            the wrong type (e.g. a refresh token used as access).
    """
    try:
        payload = jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
    except jwt.ExpiredSignatureError as e:
        raise InvalidTokenError("token expired") from e
    except jwt.InvalidTokenError as e:
        raise InvalidTokenError("invalid token") from e
    if payload.get("type") != expected_type:
        raise InvalidTokenError(f"expected {expected_type} token, got {payload.get('type')!r}")
    sub = payload.get("sub")
    if not isinstance(sub, str):
        raise InvalidTokenError("token missing sub claim")
    try:
        return UUID(sub)
    except ValueError as e:
        raise InvalidTokenError("token sub is not a UUID") from e
