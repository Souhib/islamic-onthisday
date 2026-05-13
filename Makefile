# Single-command dev convenience. Run `make dev` to boot backend + web
# together (without docker). `make check` is the local CI gate.

.PHONY: help install build dev dev-backend dev-web dev-pipeline check fix test clean mobile-release-android mobile-release-ios mobile-screenshots

help:
	@echo "Targets:"
	@echo "  install       Install everything (uv sync + bun install)"
	@echo "  build         Rebuild the pipeline DB from curated YAML"
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

# Mobile release builds. ``MOBILE_SENTRY_DSN`` and ``MOBILE_SENTRY_ENV``
# default to the production GlitchTip project / "production"; override on
# the CLI for staging / dev (e.g. ``make mobile-release-android
# MOBILE_SENTRY_ENV=staging``). Both targets bake the DSN at compile
# time — without the DSN the SDK is dormant in the shipped build.
MOBILE_SENTRY_DSN ?= https://99c06bfdda6341c68e47548c8c75030d@glitchtip.majlisna.app/5
MOBILE_SENTRY_ENV ?= production

# Umami analytics — same self-hosted instance the web hits. Page views
# and custom events POST to ``{URL}/api/send``; ``data.platform`` tags
# every payload with ``ios`` / ``android`` so the shared Thaqafa
# dashboard splits surfaces. Defaults are baked because the values
# aren't secret (the website ID ships in every web page-view request,
# and the URL is named in the public privacy policy). Override on the
# CLI for staging / a separate mobile site:
#   make mobile-release-ios MOBILE_UMAMI_URL=https://other MOBILE_UMAMI_WEBSITE_ID=…
MOBILE_UMAMI_URL ?= https://analytics.majlisna.app
MOBILE_UMAMI_WEBSITE_ID ?= 32c1add7-0f09-47a7-846e-3c5f9c188454

mobile-release-android:
	cd mobile && flutter build appbundle --release \
		--dart-define=SENTRY_DSN=$(MOBILE_SENTRY_DSN) \
		--dart-define=SENTRY_ENV=$(MOBILE_SENTRY_ENV) \
		--dart-define=UMAMI_URL=$(MOBILE_UMAMI_URL) \
		--dart-define=UMAMI_WEBSITE_ID=$(MOBILE_UMAMI_WEBSITE_ID)
	@echo "→ aab: mobile/build/app/outputs/bundle/release/app-release.aab"

mobile-release-ios:
	cd mobile && flutter build ipa --release \
		--export-options-plist=ios/ExportOptions.plist \
		--dart-define=SENTRY_DSN=$(MOBILE_SENTRY_DSN) \
		--dart-define=SENTRY_ENV=$(MOBILE_SENTRY_ENV) \
		--dart-define=UMAMI_URL=$(MOBILE_UMAMI_URL) \
		--dart-define=UMAMI_WEBSITE_ID=$(MOBILE_UMAMI_WEBSITE_ID)
	@echo "→ ipa: mobile/build/ios/ipa/Thaqafa.ipa"

# Capture App Store / Play Store screenshots from a booted simulator.
# The script drives a deterministic flow (Today → Detail → Recent →
# Observances → Bookmarks → Settings) and dumps the PNGs under
# ``mobile/screenshots/``. Booting the right simulator size first is on
# the operator (iPhone 6.7" + iPad 12.9" for Apple, Pixel 8 for Play).
mobile-screenshots:
	cd mobile && flutter run -d booted \
		--dart-define=SCREENSHOT_MODE=true \
		--target=lib/main.dart
