# Multi-stage build for the islamic-onthisday backend.
#
# Stage `dev`     — deps + code only. The SQLite is bind-mounted from the
#                    host in `docker-compose.yml` so the pipeline can be
#                    rebuilt outside the container.
# Stage `production` — runs the pipeline at build time and bakes the SQLite
#                    into the image. Used by `docker-compose.dokploy.yml`.
#
# Build from the repo root: `docker build -f backend/Dockerfile .` so the
# data-pipeline package is in scope alongside backend/.
#
# The on-disk layout inside the image mirrors the repo:
#   /opt/backend/        — this service (WORKDIR)
#   /opt/data-pipeline/  — the path dep, sibling so `../data-pipeline` in
#                          pyproject.toml + uv.lock resolves correctly with
#                          no rewriting (and `uv sync --frozen` is happy).

FROM python:3.12-slim AS base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
RUN pip install --no-cache-dir uv

# ─── Builder: install deps into /opt/backend/.venv ───────────────────────
FROM base AS builder
COPY data-pipeline /opt/data-pipeline
WORKDIR /opt/backend
COPY backend/pyproject.toml backend/uv.lock ./
COPY backend/iotd ./iotd
RUN uv sync --frozen --no-dev

# ─── Pipeline runner: produces SQLite + /opt/web/public/ static files ────
# Splits into its own stage so the layer cache invalidates only when YAML
# (or pipeline source) changes, not when backend code changes.
FROM builder AS pipeline
ENV PATH="/opt/backend/.venv/bin:$PATH"
ARG FRONTEND_URL=http://localhost
ENV FRONTEND_URL=$FRONTEND_URL
WORKDIR /opt/data-pipeline
RUN python -m pipeline.build

# ─── Dev: deps + code, no SQLite. Host bind-mounts the pipeline output. ──
FROM base AS dev
COPY --from=builder /opt/data-pipeline /opt/data-pipeline
WORKDIR /opt/backend
COPY --from=builder /opt/backend/.venv ./.venv
COPY --from=builder /opt/backend/iotd ./iotd
COPY backend/main.py ./main.py
ENV PATH="/opt/backend/.venv/bin:$PATH"
EXPOSE 5111
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5111/api/v1/health').read()" || exit 1
CMD ["python", "main.py"]

# ─── Production: SQLite baked in from the pipeline stage. ────────────────
FROM dev AS production
COPY --from=pipeline /opt/data-pipeline/data/output /opt/data-pipeline/data/output
