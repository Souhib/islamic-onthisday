# Multi-stage build for the thaqafa backend.
#
# Stage `dev`        — deps + code only. The SQLite is bind-mounted from
#                      the host in `docker-compose.yml` so the pipeline
#                      can be rebuilt outside the container.
# Stage `production` — same image as dev plus an entrypoint that runs
#                      ``python -m pipeline.build`` against the
#                      ``DATABASE_URL`` (PostgreSQL in prod) before
#                      starting the API. The pipeline drops + recreates
#                      *only* the content tables; user data persists.
#                      Used by ``docker-compose.dokploy.yml``.
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
COPY backend/thaqafa ./thaqafa
RUN uv sync --frozen --no-dev

# ─── Dev: deps + code, no SQLite. Host bind-mounts the pipeline output. ──
FROM base AS dev
COPY --from=builder /opt/data-pipeline /opt/data-pipeline
WORKDIR /opt/backend
COPY --from=builder /opt/backend/.venv ./.venv
COPY --from=builder /opt/backend/thaqafa ./thaqafa
COPY backend/main.py ./main.py
COPY backend/scripts ./scripts
ENV PATH="/opt/backend/.venv/bin:$PATH"
EXPOSE 5111
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5111/api/v1/health').read()" || exit 1
CMD ["python", "main.py"]

# ─── Production: pipeline-then-backend at container start. ───────────────
# The entrypoint runs ``pipeline.build`` against the production DATABASE_URL
# (postgres in compose), which drops + recreates the content tables from
# YAML and leaves user tables alone. Then it execs the API.
FROM dev AS production
COPY backend/entrypoint.sh /opt/backend/entrypoint.sh
RUN chmod +x /opt/backend/entrypoint.sh
ENTRYPOINT ["/opt/backend/entrypoint.sh"]
CMD []
