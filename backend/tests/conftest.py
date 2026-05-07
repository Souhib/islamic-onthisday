"""Shared pytest fixtures.

The Majlisna rule (and Souhib's standing preference) is that DB-touching
tests run against a real database, never a mock. We default to the
data-pipeline's SQLite output — every test uses the same read-only DB the
production API serves.
"""

import asyncio
from collections.abc import AsyncIterator

import pytest
from httpx import ASGITransport, AsyncClient

from thaqafa.app import create_app
from thaqafa.database import dispose_engine, init_engine
from thaqafa.settings import get_settings


@pytest.fixture(scope="session")
def event_loop():
    """One loop per session keeps the asyncpg / aiosqlite engine warm."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def app():
    """Build the FastAPI app once and tear it down at session end.

    We initialise the engine outside the app's lifespan so the test client
    can hit endpoints without round-tripping through ASGI startup events
    on every request.
    """
    settings = get_settings()
    await init_engine(settings)
    yield create_app(settings)
    await dispose_engine()


@pytest.fixture
async def client(app) -> AsyncIterator[AsyncClient]:
    """An httpx ``AsyncClient`` bound to the in-process FastAPI app."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
