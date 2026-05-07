# Multi-stage build for the thaqafa frontend.
#
# Vite picks up everything under `web/public/` and bundles it into the
# build output. The pipeline writes sitemap.xml, robots.txt, feed.xml and
# dataset-meta.json to that folder — we run the pipeline as Stage 1 so its
# output is available before `bun run build` in Stage 2.
#
# Build from the repo root: `docker build -f web/Dockerfile .` so the
# data-pipeline package is in scope alongside web/.

# ─── Stage 1: pipeline → /opt/web/public/ static files ──────────────────
FROM python:3.12-slim AS pipeline
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /opt/data-pipeline
RUN pip install --no-cache-dir uv
COPY data-pipeline /opt/data-pipeline
RUN uv sync --frozen --no-dev
ENV PATH="/opt/data-pipeline/.venv/bin:$PATH"
ARG FRONTEND_URL=http://localhost
ENV FRONTEND_URL=$FRONTEND_URL
RUN python -m pipeline.build

# ─── Stage 2: bun build the SPA ─────────────────────────────────────────
FROM oven/bun:1-alpine AS build
WORKDIR /app
COPY web/package.json web/bun.lock ./
RUN bun install --frozen-lockfile
COPY web ./
# Pipeline-generated public files override anything from the source tree.
COPY --from=pipeline /opt/web/public ./public
ARG VITE_API_URL=
ARG VITE_SENTRY_DSN=
ARG VITE_UMAMI_URL=
ARG VITE_UMAMI_WEBSITE_ID=
ENV VITE_API_URL=$VITE_API_URL \
    VITE_SENTRY_DSN=$VITE_SENTRY_DSN \
    VITE_UMAMI_URL=$VITE_UMAMI_URL \
    VITE_UMAMI_WEBSITE_ID=$VITE_UMAMI_WEBSITE_ID \
    NODE_OPTIONS=--max-old-space-size=4096
RUN bun run build

# ─── Stage 3: nginx serves the SPA + proxies /api/ to the backend ───────
FROM nginx:alpine AS production
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
