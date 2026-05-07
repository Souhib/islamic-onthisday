"""Process entry — runs the FastAPI app under uvicorn.

Used in development (``uv run python main.py``) and inside the container
image. Production deployments typically run uvicorn with ``--workers`` and a
process manager rather than this module, but the lifespan hook in
``thaqafa.app`` is the same in both cases.
"""

import uvicorn

from thaqafa.app import app
from thaqafa.settings import get_settings


def main() -> None:
    """Boot uvicorn with settings drawn from the active environment."""
    settings = get_settings()
    uvicorn.run(
        app,
        host=settings.host,
        port=settings.port,
        log_level=settings.log_level.lower(),
        proxy_headers=True,
    )


if __name__ == "__main__":
    main()
