#!/bin/sh
# Production entrypoint: rebuild the dataset against the live DATABASE_URL,
# then exec the API. The pipeline only drops the tables in
# ``CONTENT_TABLE_NAMES`` (events, lessons, observances, …) — backend
# tables (users, bookmarks, tokens) are left alone.
#
# Run on every container start, including each Dokploy redeploy. Postgres
# is the persistent layer; the dataset is the build artifact.

set -e

echo "[entrypoint] running pipeline.build against DATABASE_URL=${DATABASE_URL%@*}@…"
cd /opt/data-pipeline
python -m pipeline.build

echo "[entrypoint] starting API"
cd /opt/backend
exec python main.py
