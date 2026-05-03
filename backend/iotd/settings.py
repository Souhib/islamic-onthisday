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
