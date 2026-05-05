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

FROM python:3.12-slim AS base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app
RUN pip install --no-cache-dir uv

# ─── Builder: backend deps + pipeline path-dep installed into /app/.venv ──
# The path dep declared in backend/pyproject.toml points at "../data-pipeline"
# in the repo; we rewrite it to `/opt/data-pipeline` so uv finds the package
# inside the build context.
FROM base AS builder
COPY data-pipeline /opt/data-pipeline
COPY backend/pyproject.toml backend/uv.lock ./
COPY backend/iotd ./iotd
RUN sed -i 's|path = "../data-pipeline"|path = "/opt/data-pipeline"|' pyproject.toml
RUN uv sync --frozen --no-dev

# ─── Pipeline runner: produces SQLite + /opt/web/public/ static files ────
# Split into its own stage so the layer cache invalidates only when YAML
# (or pipeline source) changes, not when backend code changes.
FROM builder AS pipeline
ENV PATH="/app/.venv/bin:$PATH"
ARG FRONTEND_URL=http://localhost
ENV FRONTEND_URL=$FRONTEND_URL
WORKDIR /opt/data-pipeline
RUN python -m pipeline.build

# ─── Dev: deps + code, no SQLite. Host bind-mounts the pipeline output. ──
FROM base AS dev
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /opt/data-pipeline /opt/data-pipeline
COPY --from=builder /app/iotd /app/iotd
COPY backend/main.py /app/main.py
ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 5111
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5111/health').read()" || exit 1
CMD ["python", "main.py"]

# ─── Production: SQLite baked in from the pipeline stage. ────────────────
FROM dev AS production
COPY --from=pipeline /opt/data-pipeline/data/output /opt/data-pipeline/data/output
