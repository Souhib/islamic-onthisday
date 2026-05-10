#!/bin/sh
# Production entrypoint: rebuild the dataset against the live DATABASE_URL,
# then exec the API. The pipeline only drops the tables in
# ``CONTENT_TABLE_NAMES`` (events, lessons, observances, …) — backend
# tables (users, bookmarks, tokens) are left alone.
#
# Run on every container start, including each Dokploy redeploy. Postgres
# is the persistent layer; the dataset is the build artifact.

set -e

# Log a password-masked URL so docker logs / Dokploy logs don't leak the
# DB credential. SQLAlchemy's URL renderer does the masking.
SAFE_URL=$(python -c '
import os
from sqlalchemy.engine.url import make_url
print(make_url(os.environ["DATABASE_URL"]).render_as_string(hide_password=True))
')
echo "[entrypoint] running pipeline.build against $SAFE_URL"

cd /opt/data-pipeline
python -m pipeline.build

echo "[entrypoint] starting API"
cd /opt/backend
exec python main.py
