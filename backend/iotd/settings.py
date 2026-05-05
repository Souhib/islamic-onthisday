"""Application settings — pydantic-settings with per-environment .env loading.

Mirrors the Majlisna / LaTabdhir pattern: a top-level ``.env`` carries only the
``IOTD_ENV`` selector, and the matching ``.env.{env}`` file holds the actual
configuration. ``.env.local`` overrides everything for one-machine tweaks.
"""

import json
import os
from pathlib import Path

from dotenv import dotenv_values
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_BACKEND_DIR = Path(__file__).resolve().parent.parent


def _resolve_env_files() -> tuple[str, ...]:
    """Pick the chain of .env files to load, ordered most-general → most-specific.

    Resolution order for the environment selector:
        1. ``IOTD_ENV`` shell variable (CI / Docker)
        2. ``IOTD_ENV`` value in the top-level ``.env``
        3. fallback to ``"development"``

    Returns:
        Absolute paths to ``.env``, ``.env.<env>``, and (if present)
        ``.env.local`` — the last file wins.
    """
    env = os.environ.get("IOTD_ENV") or dotenv_values(_BACKEND_DIR / ".env").get("IOTD_ENV") or "development"
    files = [_BACKEND_DIR / ".env", _BACKEND_DIR / f".env.{env}"]
    local = _BACKEND_DIR / ".env.local"
    if local.exists():
        files.append(local)
    return tuple(str(f) for f in files if f.exists())


class Settings(BaseSettings):
    """Runtime configuration for the API."""

    model_config = SettingsConfigDict(env_file=_resolve_env_files(), env_file_encoding="utf-8", extra="ignore")

    # Environment selector — used by ``_resolve_env_files`` and any code that
    # needs to branch on environment.
    iotd_env: str = "development"

    # API
    port: int = 5111
    host: str = "127.0.0.1"
    # Accepts a JSON array (``["http://a","http://b"]``) or a comma-separated
    # string (``http://a,http://b``). Validator below normalises to ``list[str]``.
    cors_origins: str | list[str] = "http://localhost:3000"

    # Database. Defaults to the SQLite file the data-pipeline produces.
    database_url: str = (
        f"sqlite+aiosqlite:///{_BACKEND_DIR.parent / 'data-pipeline' / 'data' / 'output' / 'islamic_onthisday.db'}"
    )

    # Connection pool — applied only to non-sqlite URLs (asyncpg etc.).
    db_pool_size: int = 10
    db_max_overflow: int = 20
    db_pool_timeout: int = 30
    db_pool_recycle: int = 3600

    # Logging
    log_level: str = "INFO"
    log_serialize: bool = False  # JSON when true (production)

    # Sentry. Empty DSN = disabled — keeps the dev path zero-config.
    sentry_dsn: str = ""
    sentry_traces_sample_rate: float = 0.1

    # Rate limiting. Off by default in dev so tests + manual probing don't
    # hit the public limit; the production env file flips this to true.
    rate_limit_enabled: bool = False

    # Auth — JWT signing. The ``dev-only-change-me`` default exists so a
    # fresh checkout boots without env wiring; production envs MUST set
    # ``JWT_SECRET_KEY`` to a long, random value (32+ bytes).
    jwt_secret_key: str = "dev-only-change-me"
    jwt_algorithm: str = "HS256"
    access_token_minutes: int = 30
    refresh_token_days: int = 30

    # Email — Resend transactional API. Empty key = no-op (logs the would-be
    # send and returns success), so dev runs / tests never hit the network.
    # Same gating pattern as ``sentry_dsn`` above. ``email_from_address``
    # piggybacks on the verified ``majlisna.app`` Resend domain (the free
    # plan only allows one domain); the From-name distinguishes products at
    # the recipient end ("Islamic On This Day <noreply@majlisna.app>").
    resend_api_key: str = ""
    email_from_address: str = "noreply@majlisna.app"
    email_from_name: str = "Islamic On This Day"
    # Public origin used in email links (password reset, etc.). Production
    # sets this to ``https://news.majlisna.app``.
    frontend_url: str = "http://localhost:3000"
    # Password reset tokens are short-lived; the user has to request a new
    # one rather than chain old links. 30 minutes mirrors the access token
    # window we already use elsewhere.
    password_reset_token_minutes: int = 30
    # Email verification is less time-sensitive (the user often clicks
    # later, from a different device) — 48 hours gives them room without
    # making the link forever-valid.
    email_verification_token_hours: int = 48

    @field_validator("cors_origins", mode="after")
    @classmethod
    def _parse_cors_origins(cls, value: str | list[str]) -> list[str]:
        """Normalise ``CORS_ORIGINS`` into ``list[str]``.

        Accepts:
          - ``["http://a","http://b"]`` — JSON array (parsed via ``json.loads``).
          - ``http://a,http://b`` — comma-separated string.
          - ``["http://a"]`` — already a list (test rigs / programmatic use).
        """
        if isinstance(value, list):
            return [str(v) for v in value]
        stripped = value.strip()
        if stripped.startswith("["):
            return list(json.loads(stripped))
        return [item.strip() for item in stripped.split(",") if item.strip()]


def get_settings() -> Settings:
    """Build a fresh ``Settings`` instance.

    Returns:
        A populated ``Settings`` for the current environment.
    """
    return Settings()
