# backend/

FastAPI service for Islamic On This Day. Read-only over the SQLite database
the `data-pipeline/` produces.

Layout mirrors the canonical Souhib FastAPI shape used in
[Majlisna](../IPG/) and [LaTabdhir](../LaTabdhir/):

```
backend/
├── main.py                  # uvicorn entry
├── pyproject.toml
├── Dockerfile
├── .env / .env.development / .env.example
├── iotd/
│   ├── app.py               # create_app(settings) factory + lifespan
│   ├── settings.py          # pydantic-settings, IOTD_ENV selector
│   ├── database.py          # async engine, get_session
│   ├── dependencies.py      # FastAPI Depends(...) providers
│   ├── logger_config.py     # loguru setup
│   ├── observability.py     # Sentry init (gated on $SENTRY_DSN)
│   └── api/
│       ├── cache.py         # Cache-Control dependencies (CACHE_DAY, CACHE_HOUR, …)
│       ├── constants.py     # Hijri / Gregorian month names, limits
│       ├── errors.py        # BaseError + typed per-resource subclasses
│       ├── middleware.py    # pure ASGI: SecurityMiddleware, RequestID, Logging
│       ├── routes/          # thin — delegate to controllers, attach Cache-Control
│       ├── controllers/     # one class per resource — DB queries + raise typed errors
│       ├── schemas/         # Pydantic response models (camelCase JSON via to_camel)
│       ├── services/
│       │   ├── projections.py   # ORM row → response model — pure functions
│       │   └── calendar.py      # Gregorian / Hijri pairing helpers
│       └── utils/
│           └── cache.py     # in-memory TTL cache (for hot endpoints, optional)
└── tests/                   # pytest, asyncio_mode=auto, real DB
```

## Setup

```sh
cd backend
uv sync
uv run python main.py            # http://127.0.0.1:5111
# or
uv run poe dev                   # uvicorn --reload
```

`uv sync` will install the `data-pipeline` package as a path dependency so
the API and the pipeline stay schema-coherent. Build the pipeline DB once
before the first run: `cd ../data-pipeline && uv run python -m pipeline.build`.

## Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Liveness + DB ping + dataset snapshot (counts + freshness). |
| `GET` | `/api/v1/today` | Today's headline + secondary rails + observance. |
| `GET` | `/api/v1/recent?days=7` | Last N days of headlines (events + lesson fallbacks). |
| `GET` | `/api/v1/events` | Paginated event list with filters. |
| `GET` | `/api/v1/events/{slug}` | Full event detail. |
| `GET` | `/api/v1/lessons` / `/lessons/{slug}` | Dateless lessons. |
| `GET` | `/api/v1/observances` / `/observances/{slug}` | Recurring annual observances. |
| `GET` | `/api/v1/people/{slug}` | Person profile (image policy enforced). |

OpenAPI: `http://127.0.0.1:5111/docs`. The generated JSON spec lives at
`backend/openapi.json` and is mirrored to `web/openapi.json` for client
generation.

## Conventions

These are the rules the current shape was built around — read these
before changing the controller / route layer.

1. **Route → Controller → Projection.** Routes have zero business
   logic: they `Depends(...)` a controller, call one method, return its
   result. Cache-Control is attached via `dependencies=[CACHE_*]` on the
   route decorator (see `iotd/api/cache.py`), never set inside the
   handler. Controllers run the queries and raise typed errors.
   ORM-row → response-schema mapping lives in `services/projections.py`.
2. **Snake-case discriminants over English labels.** `verification_status`,
   `dispute_about`, `weight` are `Literal[...]` discriminants. The API
   never emits a human-readable label — the FE owns rendering via i18n.
3. **One typed error per resource.** `EventNotFoundError`,
   `LessonNotFoundError`, etc. — derived from `BaseError`. The base
   auto-generates `error_key` from the class name (`EventNotFoundError`
   → `errors.api.eventNotFound`) and self-logs at smart per-status
   defaults: 5xx → ERROR, 401/403/409 → WARNING, 4xx → DEBUG. Pass
   `log=False` if you're raising inside a try/except that's about to
   handle the error locally — keeps the log stream clean.
4. **Pure ASGI middleware, not `BaseHTTPMiddleware`.** Lower overhead
   under load (Majlisna pattern).
5. **No `?on=YYYY-MM-DD` on the public Today route.** Daily-ritual
   constraint — letting users binge through arbitrary calendar dates
   would dissolve the project's cadence. Permalinks live on
   `/api/v1/events/{slug}`.
6. **All DB ops async** (`AsyncSession`, `await session.exec(...)`).
7. **Schemas inherit `BaseModel`** from `iotd.api.schemas.shared`
   (which re-exports the pipeline base — single source of truth).
8. **No `dict[str, Any]` at API boundaries.** Build a Pydantic schema.
9. **Loguru with `.bind(...)`** for structured fields. Never f-string
   inside `logger.info(...)`.
10. **Constants in `constants.py`** — no magic numbers inline.
11. **Tests hit the real DB.** No mock sessions.

## Development tasks

```sh
uv run poe check          # ruff lint + format check
uv run poe fix            # ruff format + lint --fix
uv run poe test           # pytest
uv run poe test-fast      # pytest -x
uv run poe dev            # uvicorn --reload
```

## Cache-Control vocabulary

Always pick from `iotd/api/cache.py` rather than inlining a string:

| Dependency | Policy | Used by |
|---|---|---|
| `CACHE_UNTIL_MIDNIGHT` | `max-age=<seconds-until-UTC-midnight>` | `/today`, `/recent` |
| `CACHE_DAY` | `max-age=86400, s-maxage=604800` | `/observances` |
| `CACHE_HOUR` | `max-age=3600, s-maxage=86400` | `/events/{slug}`, `/lessons/{slug}`, `/people/{slug}` |
| `CACHE_FIVE_MIN` | `max-age=300, s-maxage=900` | list endpoints |
| `NO_STORE` | `no-store` | `/health` |

## Pipeline ↔ backend handoff

The backend reads the SQLite the pipeline writes. They share **one DB**
(future user tables will live alongside the dataset tables — see
`pipeline/constants.py:CONTENT_TABLE_NAMES` for the allowlist the
pipeline is permitted to drop). Three operational consequences:

1. **Pipeline rebuild is destructive for content tables only.** Running
   `pipeline.build` drops + recreates events/lessons/observances/people/
   sources/etc. User tables, when added, are untouched.
2. **The backend's engine should be cycled when the pipeline rebuilds**
   so SQLAlchemy doesn't hold stale rows in its identity map. In
   production this means: drain → run pipeline → restart API. For dev
   you can ignore it; the next request reads fresh rows.
3. **Cron the pipeline once a day.** `pipeline.build` regenerates both
   the SQLite and the syndication files (`web/public/{sitemap.xml,
   robots.txt, feed.xml}`). The Atom feed needs to roll daily even when
   the dataset is stable, so a daily run is non-negotiable.

## Environments

`.env` carries only the `IOTD_ENV` selector. The matching `.env.<env>` file
holds real config. `.env.local` (gitignored) overrides everything for
single-machine tweaks.

```
IOTD_ENV=development      # → loads .env.development next, then .env.local
```

## Environment variables

| Var                          | Purpose                                                |
| ---------------------------- | ------------------------------------------------------ |
| `IOTD_ENV`                   | Selects which `.env.{env}` file to load.               |
| `HOST` / `PORT`              | uvicorn bind.                                          |
| `DATABASE_URL`               | Defaults to the pipeline's SQLite path.                |
| `DB_POOL_SIZE` / `DB_MAX_OVERFLOW` / `DB_POOL_TIMEOUT` / `DB_POOL_RECYCLE` | PostgreSQL pool tuning (ignored for SQLite). |
| `CORS_ORIGINS`               | JSON array or comma-separated origins.                 |
| `LOG_LEVEL` / `LOG_SERIALIZE` | Loguru level + JSON-vs-pretty toggle.                 |
| `SENTRY_DSN`                 | Empty disables Sentry; non-empty wires init.           |
| `SENTRY_TRACES_SAMPLE_RATE`  | Default `0.1`.                                         |
