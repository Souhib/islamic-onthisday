<p align="center">
  <img src="docs/brand/lockup@2x.png" alt="Thaqafa — ثقافة" width="460" />
</p>

<p align="center">
  <a href="https://github.com/Souhib/thaqafa/actions/workflows/ci.yml"><img src="https://github.com/Souhib/thaqafa/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" /></a>
</p>

A website and backend (Flutter mobile app planned) that surface a verified
historical event from Islamic history for each day of the year (Gregorian
and Hijri).

Live repo: <https://github.com/Souhib/thaqafa>.

The repository ships three components:

- **`data-pipeline/`** — Python ETL that turns curated YAML into the
  authoritative SQLite database, and emits the public sitemap / robots /
  Atom feed / dataset-meta alongside it. Bulk discovery from Wikidata /
  OpenITI lives under `data-pipeline/scripts/discovery/` and produces
  JSON candidate reports for human review — never writes to the
  production SQLite.
- **`backend/`** — FastAPI read-only API serving the dataset to the web
  client. Private origin: only the FE talks to it.
- **`web/`** — Vite + React reading surface (Tailwind v4, i18next, TanStack
  Router + Query, custom editorial design system).

## Current status

- **Data pipeline: curated.** 1,256 hand-curated events (448 day-precise, 1,117 cross-verified across ≥2 classical Sunni sources, 84 with disputed dates surfaced explicitly), 353 dateless lessons, 12 annual observances, 860 historical figures, 26 citable sources. Strict editorial bar: trilingual (en/ar/fr), classical Sunni source citations, ṣaḥīḥ-only hadith policy, Wikidata QIDs verified per-entry. Every event in the dataset is at least `single_source`. Bulk Wikidata + OpenITI imports remain available via `pipeline.build --include-bulk` for catalogue depth, but the headline picker only surfaces curated entries.
- **Backend (FastAPI): functional.** Today / Recent / Events / Lessons /
  Observances / People endpoints, typed errors with auto-derived i18n keys,
  Cache-Control via dependencies, pure-ASGI middleware (security headers +
  request id + slow-request logging), full pytest suite against the real
  pipeline DB.
- **Web (Vite + React): functional.** Trilingual (en/fr/ar) with RTL,
  light/dark theme via CSS variables, custom editorial primitives
  (frieze rosettes, eight-point stars, verification dot-chips), TanStack
  Router file-based routing, TanStack Query + auto-generated hey-api
  client, Radix dialog under the disputed-views drawer.
- **Mobile (Flutter): not started.**

## Quickstart

After a fresh clone, the easiest path is the root `Makefile`:

```sh
make install            # uv sync (data-pipeline + backend) + bun install (web)
make build              # rebuilds the pipeline DB + syndication files (one-shot)
make dev                # boots backend (:5111) + web (:3000) in parallel
make check              # lint + typecheck + tests across all three packages
```

Per-package commands are detailed further down (Running the pipeline /
backend / web client). `make build` is required after a first clone
because the backend reads the SQLite the pipeline produces; without it
`/api/v1/today` will fail to start.

## Database snapshot

Numbers below reflect the curated YAML at `data-pipeline/data/curated/`
— `pipeline.build` produces exactly this. Live counts on a running
backend are at `GET /health`. The build is curated-only: no auto-
ingestion path, no `--include-bulk` flag, no `auto_verified` tier.
Every entry has been editorially reviewed.

| Metric                                       | Count |
| -------------------------------------------- | ----: |
| Events (total)                               | 1,256 |
| — Importance = major (headline candidates)   | 254 |
| — Importance = notable                       | 1,002 |
| — Verification = cross_verified (≥2 sources) | 1,117 |
| — Verification = single_source               | 139 |
| — Disputed (multiple attested positions)     | 84 |
| Events by precision — day-precise            | 448 |
| — month-precise                              | 198 |
| — year-precise                               | 610 |
| Persons                                      | 860 |
| Date claims (with provenance)                | 3,237 |
| Event ↔ person links                         | 1,325 |
| Citable sources                              | 26 |
| Tags                                         | 1,915 |
| Dateless Qur'an / Sunnah lessons             | 353 |
| **Annual Islamic observances** (recurring Hijri dates) | **12** |
| Gregorian days with ≥1 day-precise event     | 251 / 366 |
| Distinct Hijri month-day slots covered       | 238 / 354 |
| Headline-worthy (major ∩ verified)           | 193 |

Top event categories:

| Category               | Events |
| ---------------------- | ----: |
| Scholar deaths         | 419 |
| Scholars (other)       | 228 |
| Ruler deaths           | 123 |
| Battles                | 91 |
| Companions             | 61 |
| Conquests              | 60 |
| Political events       | 47 |
| Foundings              | 35 |
| Rulers                 | 28 |
| Rashidun               | 18 |
| Prophetic era          | 17 |
| Sieges                 | 15 |
| Umayyad                | 15 |
| Dynastic foundings     | 11 |

Dateless lessons:

| Category               | Count |
| ---------------------- | ----: |
| Qur'an stories         | 97 |
| Sunnah practices       | 88 |
| Qur'an / Hadith facts  | 86 |
| Hadith narratives      | 82 |

## Data source: curated YAML only

`data-pipeline/data/curated/` is the authoritative — and sole — input
to `pipeline.build`. Every entry is hand-written and verified against
classical sources (al-Ṭabarī, Ibn Kathīr, al-Dhahabī, Ibn Ḥajar, Ṣaḥīḥ
al-Bukhārī, Ṣaḥīḥ Muslim, etc.). Each event cites at least one classical
source plus, where relevant, modern academic corroboration. Events with
disputed dates (e.g. the death of the Prophet ﷺ) carry multiple `claims`
so the dispute is modelled in data, not hidden.

Structure:
- `sources.yaml` — citable reference works.
- `people.yaml` — historical figures (with religious-prohibition flags).
- `events/*.yaml` — dated events split by era: 00_legacy, 01_prophetic,
  02_rashidun, 03_umayyad_abbasid, 04_andalus, 06_scholars, etc. Every
  `.yaml` file in the directory is loaded.
- `lessons/*.yaml` — dateless Qur'an / Sunnah lessons, split by category:
  01_prophets, 02_hadith_narratives, 03_sunnah_practices, etc.
- `observances.yaml` — annual recurring sacred days (ʿĪd, ʿArafah,
  Laylat al-Qadr window, etc.).

### Discovery (out-of-band)

Two helper scripts under `data-pipeline/scripts/discovery/` query
Wikidata SPARQL and OpenITI metadata to surface *candidate* entries the
curator might want to add to YAML. They write JSON reports — never the
SQLite — so the editorial bar always applies before anything reaches
the API. Run them when you want to take a discovery pass; ignore them
otherwise.

## Calendar handling

Hijri <-> Gregorian conversion uses the classical tabular algorithm via
`convertdate.islamic`. It works from 622 CE onward but is inherently
approximate — a converted date can diverge from the historically observed
date by ±1-3 days. The pipeline treats attested Gregorian dates (in the
curated YAML) as authoritative and uses tabular conversion only as fallback.

Date claims carry a `gregorian_method` tag so the UI can label a date:

- `attested` — historically recorded in a classical primary source.
- `tabular_conversion` — computed from the Hijri date via the algorithm.
- `reconstructed` — inferred by scholars without an explicit source.

## Accuracy policy

The user requirement is 100% accuracy. In practice, this means:

1. **No fabricated day-precision.** When classical sources record only the
   year or only the month, the event stays at that precision. It is never
   promoted to a day by guessing.
2. **Disputes are data, not editorial.** Events like the Prophet's ﷺ death
   date (12 vs. 2 vs. 1 Rabi al-Awwal 11 AH) carry all attested positions in
   the `date_claims` table. The canonical view is the majority classical
   position, but the UI can and should surface the alternatives.
3. **Every entry is editorially reviewed.** There is no auto-ingestion;
   the `verified` boolean is set only for hand-curated entries with
   confirmed classical attestation. The deprecated `auto_verified` tier
   was retired — the API now exposes only `single_source`,
   `cross_verified`, `scholar_reviewed`, and `unverified`.
4. **Day-precision drives UI defaults.** "On this day" tiles draw from
   day-precise events first, then month/year-precise fallbacks. No
   calendar day is ever empty because dateless lessons fill any
   remaining gap.

## Image policy — religious prohibition

No image is shown of:

- **The Prophet Muhammad ﷺ** or any other prophet.
- **Sahaba** (Companions of the Prophet ﷺ).
- **Ahl al-Bayt** (the People of the House).

Enforcement lives in `src/pipeline/images/fetcher.py`:

1. Any `Person` record flagged `is_prophet`, `is_sahabi`, or `is_ahl_al_bayt`
   has its image unconditionally nullified. This is the hard rule.
2. A name-based heuristic blocks Wikidata-imported persons whose names match
   known Sahabi patterns (Karbala martyrs, Banu Hashim, close Companions).
3. A date-based heuristic blocks Wikidata-imported persons whose death year
   is before 900 CE — conservatively covering the Sahaba, Tabi'un, and Tabi'
   al-Tabi'in generations.

Late-era Muslim figures (e.g. Ibn Battuta, Hafez, Mimar Sinan) retain their
images. This policy can be tightened in one place if you want a stricter
stance (e.g. blocking all human depictions for all eras).

Preferred image content for events:

- Mosques (Masjid al-Haram, al-Nabawi, al-Aqsa, Qarawiyyin, al-Azhar,
  Umayyad, Sultan Ahmed).
- Manuscripts, calligraphy, miniature art (geometric / architectural detail).
- Geographic locations (Badr, Uhud, Karbala, Qadisiyyah plains).
- Architecture (Alhambra, Mezquita of Cordoba, Dome of the Rock).

## Schema

`data-pipeline/src/pipeline/models/db.py`

```
sources              citable reference (Wikidata, OpenITI, al-Tabari, etc.)
people               historical figures (image policy applies)
events               canonical event — one row per event
date_claims          per-source date attestations; multiple per event = dispute
event_people         N:M with relation (subject, leader, killed, died, …)
tags  /  event_tags  free-form tagging
dateless_lessons     Quran / Sunnah content without a specific date;
                     each has stable display_day_of_year (1-366) for rotation
images               blob / URL cache with license + attribution
```

The schema is SQLAlchemy 2.0 typed ORM, targeting PostgreSQL — SQLite is the
development target, no Postgres-specific features are used.

## Running the pipeline

```sh
cd data-pipeline
uv sync
uv run python -m pipeline.build                      # full rebuild from curated YAML
uv run python -m pipeline.syndicate                  # refresh sitemap/robots/feed only
uv run python -m pipeline.validate                   # check refs + disputed flags
# Discovery (manual, never feeds the production SQLite):
# uv run python scripts/discovery/wikidata_leads.py  # candidate report → JSON
# uv run python scripts/discovery/openiti_leads.py   # candidate report → JSON
```

The pipeline writes to two destinations:

- `data-pipeline/data/output/thaqafa.db` — the SQLite consumed by
  the FastAPI backend.
- `web/public/{sitemap.xml, robots.txt, feed.xml}` — public syndication files
  that the FE bundle ships as static assets. `sitemap.xml` lists every event /
  lesson / observance / person URL for crawlers; `feed.xml` is the Atom 1.0
  feed of the last 14 days of headlines; `robots.txt` points to the sitemap
  and blocks AI scrapers. `pipeline.build` regenerates all of them; the
  shorter `pipeline.syndicate` command refreshes only the syndication files
  (useful as a daily cron when the dataset is stable but the feed needs to
  roll forward).

Set `FRONTEND_URL=https://your-domain` before running so the absolute URLs
in the XML point at production rather than `http://localhost:3000`.

## Running the backend

The backend reads the SQLite produced by the pipeline; rebuild it once
before starting the API for the first time.

```sh
cd backend
uv sync
uv run python main.py        # uvicorn on :5111
uv run poe test              # pytest against the real pipeline DB
uv run poe check             # ruff lint + format check
uv run poe fix               # ruff format + lint --fix
```

The API mounts under `/api/v1`; `/health` is at the root and
`Cache-Control: no-store`. JSON keys are camelCase (Python attributes are
snake_case server-side; the wire format is aliased via Pydantic). Errors
are returned as a stable envelope:

```json
{
  "error": "EventNotFoundError",
  "error_key": "errors.api.eventNotFound",
  "message": "That event doesn't exist.",
  "error_params": {},
  "details": { "slug": "no-such-event" },
  "timestamp": "2026-05-03T01:23:45+00:00"
}
```

`error_key` is auto-derived from the exception class name and serves as the
i18n lookup key on the frontend; `details` is only populated for 4xx
status codes where field-level context is useful.

## Running the web client

```sh
cd web
bun install
bun run dev                  # vite on :3000, proxies /api → :5111
bun run build                # production bundle
bun run typecheck            # tsc -b --noEmit
bun run lint                 # oxlint
bun run test                 # vitest
bun run check                # typecheck + lint + test
bun run format               # oxfmt
bun run generate-api         # regen hey-api client from openapi.json
```

Whenever the backend schema changes, regenerate the OpenAPI client:

```sh
# from backend/
uv run python -c "import json; from thaqafa.app import create_app; print(json.dumps(create_app().openapi()))" \
  > openapi.json && cp openapi.json ../web/openapi.json
# from web/
bun run generate-api
```

## Editing curated data

The YAML files in `data-pipeline/data/curated/` are the authoritative input
for all Tier-1 events. To add an event, edit `events.yaml`. To add a
reference, edit `sources.yaml`. People are in `people.yaml`. Dateless Quran/
Sunnah lessons are in `dateless_lessons.yaml` — each needs a unique
`display_day_of_year` in the 1-366 range.

Re-run `uv run python -m pipeline.build` to regenerate the database. The
pipeline drops and recreates the schema each run; the database is ephemeral
and always derivable from the YAML + the two live sources.

## Architecture notes

**Single-database constraint.** The dataset and any future user data
(accounts, bookmarks, preferences) share **one** database. The pipeline
is allowed to drop *only* the dataset tables — the allowlist lives in
`data-pipeline/src/pipeline/constants.py:CONTENT_TABLE_NAMES`. Anything
not in that set is left alone, even when `pipeline.build` runs a full
rebuild. This means a content rebuild is non-destructive for user data,
and the architectural ambiguity ("two DBs vs. one?") is resolved up
front.

**Pipeline → backend handoff.** When the pipeline rebuilds, the SQLite
on disk is replaced. A running backend keeps its connection pool open
and may serve a mix of old/new rows for a few seconds. In production
this is mitigated by the daily-cron pattern (rebuild at low-traffic
hours) plus a backend restart in the same window. For dev, `make build`
followed by `make dev` is the usual order.

**SEO surface.** The pipeline emits `web/public/{sitemap.xml,
robots.txt, feed.xml}` at build time, so the FE host serves them as
static assets without any backend dependency. The Atom feed is the same
"last 14 days of headlines" data `/api/v1/recent` returns, in a format
RSS readers understand. Run `make syndicate` to refresh just the XMLs
without a full DB rebuild.

## Roadmap

1. **User accounts & bookmarks** (next phase). JWT auth, opt-in
   signup. Anonymous browsing stays the default — accounts unlock
   personal saves only. User tables share the SQLite with content
   tables; the pipeline's `CONTENT_TABLE_NAMES` allowlist guarantees
   content rebuilds never touch user tables.
2. **Image download + self-hosting.** Fetch Wikimedia Commons images
   (subject to the religious-image policy), store locally, record
   license/attribution.
3. **Mobile app (Flutter).**
4. **Static prerendering** of detail pages so Twitter / iMessage
   previews work; `<link rel="canonical">` + Open Graph + Schema.org
   JSON-LD.
5. **Daily content rebuild via Dokploy schedule** so the Atom feed
   rolls forward without a manual deploy.

## License

[MIT](LICENSE) — see the LICENSE file for details. The code is open
source; the editorial dataset (curated YAML under
`data-pipeline/data/curated/`) is also MIT-licensed but please respect
the editorial bar in [`EDITORIAL.md`](EDITORIAL.md) when contributing
content.

## Contributing

Content edits flow through `data-pipeline/data/curated/`. The bar is
non-negotiable — read [`EDITORIAL.md`](EDITORIAL.md) end to end before
opening a PR. The summary lives in [`CLAUDE.md`](CLAUDE.md), and the
dataset audit state and human-review backlog are in [`AUDIT.md`](AUDIT.md).

Code contributions are welcome. The CI gate is `make check`; run it
locally before pushing.
