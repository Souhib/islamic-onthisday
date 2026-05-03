# Single-command dev convenience. Run `make dev` to boot backend + web
# together (without docker). `make check` is the local CI gate.

.PHONY: help install build dev dev-backend dev-web dev-pipeline syndicate check fix test clean

help:
	@echo "Targets:"
	@echo "  install       Install everything (uv sync + bun install)"
	@echo "  build         Rebuild the pipeline DB (curated + Wikidata + OpenITI)"
	@echo "  syndicate     Refresh sitemap.xml + robots.txt + feed.xml"
	@echo "  dev           Boot backend + web together (parallel, kill with ^C)"
	@echo "  dev-backend   uvicorn on :5111"
	@echo "  dev-web       vite on :3000"
	@echo "  check         Lint + typecheck + tests across all three packages"
	@echo "  fix           ruff format + ruff fix on backend & pipeline"
	@echo "  test          Run all test suites"
	@echo "  clean         Drop venvs and node_modules"

install:
	cd data-pipeline && uv sync
	cd backend && uv sync
	cd web && bun install

build:
	cd data-pipeline && uv run python -m pipeline.build

syndicate:
	cd data-pipeline && uv run python -m pipeline.syndicate

dev-backend:
	cd backend && uv run python main.py

dev-web:
	cd web && bun run dev

# Run backend + web in parallel. Trap so ^C kills both children.
dev:
	@echo "→ booting backend (:5111) and web (:3000)…"
	@trap 'kill 0' INT; \
		( cd backend && uv run python main.py ) & \
		( cd web && bun run dev ) & \
		wait

check:
	cd data-pipeline && uv run poe check
	cd backend && uv run poe check && uv run poe test
	cd web && bun run check

fix:
	cd data-pipeline && uv run poe fix
	cd backend && uv run poe fix
	cd web && bun run format && bun run lint:fix

test:
	cd backend && uv run poe test
	cd web && bun run test

clean:
	rm -rf data-pipeline/.venv
	rm -rf backend/.venv
	rm -rf web/node_modules
