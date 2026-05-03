"""Loguru setup — single sink, structured JSON in production."""

import sys

from loguru import logger


def configure_logger(level: str = "INFO", *, serialize: bool = False) -> None:
    """Replace loguru's default sink with the application sink.

    Args:
        level: Minimum log level the sink will accept (e.g. ``"DEBUG"``).
        serialize: When ``True``, emit one JSON object per record. Use in
            production so log aggregators can index fields. When ``False``
            emit a coloured human-readable line for local development.
    """
    logger.remove()
    if serialize:
        logger.add(sys.stderr, level=level, serialize=True, enqueue=True)
    else:
        logger.add(
            sys.stderr,
            level=level,
            format=(
                "<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | "
                "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>"
            ),
            enqueue=True,
        )
