FROM python:3.12-slim AS base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app
RUN pip install --no-cache-dir uv

FROM base AS builder
COPY pyproject.toml ./
COPY iotd ./iotd
# The pipeline package is the source of truth for the schema. Copy it from
# the build context so uv can install it as the path dependency declared in
# pyproject.toml. Build with `docker build -f backend/Dockerfile .` from the
# repo root so both folders are in scope.
COPY ../data-pipeline /opt/data-pipeline
RUN sed -i 's|path = "../data-pipeline"|path = "/opt/data-pipeline"|' pyproject.toml
RUN uv sync --frozen --no-dev || uv sync --no-dev

FROM base AS production
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /opt/data-pipeline /opt/data-pipeline
COPY iotd ./iotd
COPY main.py ./
ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 5111
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5111/health').read()" || exit 1
CMD ["python", "main.py"]
