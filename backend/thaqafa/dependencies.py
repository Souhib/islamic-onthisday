"""FastAPI dependency providers — controllers are fully wired here.

Routers must never instantiate controllers directly; they receive pre-built
instances via ``Depends``.
"""

from typing import Annotated

from fastapi import Depends, Header
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.controllers.account import AccountController
from thaqafa.api.controllers.auth import AuthController
from thaqafa.api.controllers.bookmarks import BookmarksController
from thaqafa.api.controllers.email_verification import EmailVerificationController
from thaqafa.api.controllers.events import EventsController
from thaqafa.api.controllers.health import HealthController
from thaqafa.api.controllers.lessons import LessonsController
from thaqafa.api.controllers.observances import ObservancesController
from thaqafa.api.controllers.password_reset import PasswordResetController
from thaqafa.api.controllers.people import PeopleController
from thaqafa.api.controllers.recent import RecentController
from thaqafa.api.controllers.today import TodayController
from thaqafa.api.errors import InvalidTokenError
from thaqafa.database import get_session
from thaqafa.models.user import User
from thaqafa.settings import Settings, get_settings


async def get_today_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> TodayController:
    """Return a ``TodayController`` wired to the request session."""
    return TodayController(session)


async def get_recent_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> RecentController:
    """Return a ``RecentController`` wired to the request session.

    The recent payload no longer composes ``TodayController.today`` per-day
    (that pattern was N+1 — see ``RecentController._pick_headlines``).
    """
    return RecentController(session)


async def get_events_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> EventsController:
    """Return an ``EventsController`` wired to the request session."""
    return EventsController(session)


async def get_lessons_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> LessonsController:
    """Return a ``LessonsController`` wired to the request session."""
    return LessonsController(session)


async def get_observances_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> ObservancesController:
    """Return an ``ObservancesController`` wired to the request session."""
    return ObservancesController(session)


async def get_people_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> PeopleController:
    """Return a ``PeopleController`` wired to the request session."""
    return PeopleController(session)


async def get_health_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> HealthController:
    """Return a ``HealthController`` wired to the request session."""
    return HealthController(session)


def get_active_settings() -> Settings:
    """FastAPI dependency wrapper around ``get_settings()`` so routes can ``Depends`` it."""
    return get_settings()


async def get_auth_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
    settings: Annotated[Settings, Depends(get_active_settings)],
) -> AuthController:
    """Return an ``AuthController`` wired to the request session + settings."""
    return AuthController(session, settings)


async def get_bookmarks_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> BookmarksController:
    """Return a ``BookmarksController`` wired to the request session."""
    return BookmarksController(session)


async def get_password_reset_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
    settings: Annotated[Settings, Depends(get_active_settings)],
) -> PasswordResetController:
    """Return a ``PasswordResetController`` wired to the request session + settings."""
    return PasswordResetController(session, settings)


async def get_email_verification_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
    settings: Annotated[Settings, Depends(get_active_settings)],
) -> EmailVerificationController:
    """Return an ``EmailVerificationController`` wired to the request session + settings."""
    return EmailVerificationController(session, settings)


async def get_account_controller(
    session: Annotated[AsyncSession, Depends(get_session)],
    settings: Annotated[Settings, Depends(get_active_settings)],
) -> AccountController:
    """Return an ``AccountController`` for the /auth/me/* mutation routes."""
    return AccountController(session, settings)


async def get_current_user(
    auth: Annotated[AuthController, Depends(get_auth_controller)],
    authorization: Annotated[str | None, Header(alias="Authorization")] = None,
) -> User:
    """Resolve the bearer token in the ``Authorization`` header to an active user.

    Raises:
        InvalidTokenError: when the header is missing, malformed, or
            doesn't decode to a known active account.
    """
    if not authorization or not authorization.lower().startswith("bearer "):
        raise InvalidTokenError("missing bearer token")
    token = authorization.split(" ", 1)[1].strip()
    if not token:
        raise InvalidTokenError("empty bearer token")
    return await auth.get_current_user(token)
