# AGENTS.md

Compact operational guide for OpenCode sessions in this repo.  
For editorial rules and project background, see `CLAUDE.md`. For public overview, see `README.md`.

## Repository layout

Monorepo with three active packages. Mobile (Flutter) is not started yet.

| Directory | Tech | Role |
|---|---|---|
| `data-pipeline/` | Python 3.12 + uv | Builds the SQLite DB from curated YAML + live Wikidata + OpenITI |
| `backend/` | FastAPI + uv | Read-only API over the pipeline DB |
| `web/` | Vite + React + TypeScript + Bun | Reading surface; proxies `/api` → backend |

## Package managers

- **Python:** `uv` only. Never `pip`, bare `python`, or `poetry`.
- **Web:** `bun` only. Never `npm`, `pnpm`, or `yarn`.

## Everyday commands

### data-pipeline
Run from `data-pipeline/`:

```sh
uv sync
uv run python -m pipeline.build --skip-wikidata --skip-openiti   # curated-only rebuild
uv run python -m pipeline.validate                                # structural ref check
uv run poe check                                                  # ruff lint + format check
uv run poe fix                                                    # ruff format + lint --fix
```

The DB at `data/output/thaqafa.db` is **ephemeral** — never hand-edit it.

### backend
Run from `backend/`:

```sh
uv sync                          # installs data-pipeline as editable path dep
uv run poe dev                   # uvicorn --reload on http://127.0.0.1:5111
uv run poe check                 # ruff lint + format check
uv run poe fix                   # ruff format + lint --fix
uv run poe test                  # pytest (real DB, no mocks)
uv run poe test-fast             # pytest -x
```

### web
Run from `web/`:

```sh
bun install
bun run dev                      # http://localhost:3000
bun run check                    # typecheck + oxlint + vitest
bun run build                    # tsc + vite build
bun run test:watch               # vitest --watch
```

Dev server proxies `/api` → `http://127.0.0.1:5111` (backend).  
TanStack Router generates `src/routeTree.gen.ts` from files in `src/routes/` — the generated file is committed.

## Python conventions

- **3.12+ native syntax:** `str | None`, `list[int]`. No `from __future__ import annotations`, no `Optional`, no `List[X]`.
- **Collections from `collections.abc`** (`Iterator`, `Sequence`, `Mapping`, `Callable`), not `typing`.
- **Ruff config** is identical in both `pyproject.toml` files (line-length 120, target py312). Run `uv run poe check` before committing.
- **Backend architecture:** async DB ops (`AsyncSession`), Route → Controller → Model, no `dict[str, Any]` at API boundaries, loguru with `.bind(...)` (no f-strings in log calls).
- **Tests hit the real SQLite DB** produced by the pipeline (`backend/tests/conftest.py`).

## Web conventions

- TypeScript **strict** (no implicit `any`, no unused locals).
- **TanStack Router** file-based routing; add a file in `src/routes/` and the codegen updates `routeTree.gen.ts`.
- **TanStack Query** owns all server state — do not add Redux / Zustand.
- **Tailwind v4** + `cn()` from `@/lib/utils` for new components. The reader typographic shell uses **inline styles** intentionally — preserve that for design fidelity.
- `oxlint` for linting; no ESLint/Prettier configured.

## Editing curated data (YAML)

1. Read `EDITORIAL.md` before touching any YAML.
2. Add/modify files in `data-pipeline/data/curated/`.
3. Rebuild curated-only and validate:
   ```sh
   uv run python -m pipeline.build --skip-wikidata --skip-openiti
   uv run python -m pipeline.validate
   ```
4. Never invent day-precision when sources only attest a year or month.

## Content rules — quick reference (user requirements)

These complement `EDITORIAL.md` and are enforced on every wave:

1. **Date precision honesty.** Use only the precision the sources attest. If classical sources disagree, follow the majority opinion among named sources. If no date is attested with confidence, convert to a dateless `lesson/` instead of fabricating a year.

2. **No duplicates.** Before adding any event, grep existing `events/*.yaml` for the person, battle, or treaty. The same event under a different slug is still a duplicate.

3. **The Ibn Battuta test.** If a figure isn't directly a scholar, ruler, or military commander in Islamic history, ask: "Would an educated Muslim benefit from knowing this person? Did they change history or represent something important about the Muslim world?" If not, drop.

4. **Explain the 'so what' in every description.** Every event must answer: who was this person, what did they do, how was the world before, and how did this event change it (for its region, its era, or the future).

## Git

- **Conventional Commits with emoji scope:** `feat(api): ✨ add login flow`
- **Never add `Co-Authored-By` or AI attribution** lines.
