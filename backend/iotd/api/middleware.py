"""HTTP middleware — pure ASGI for performance.

Three middlewares, applied bottom-up in :mod:`iotd.app`:

1. :class:`SecurityMiddleware` — security headers, URL guards, query-param
   sanitisation.
2. :class:`RequestIDMiddleware` — generate / propagate ``X-Request-ID``.
3. :class:`LoggingMiddleware` — one structured loguru line per response,
   plus a slow-request warning at 1s.

We stick to pure ASGI (Starlette's ``BaseHTTPMiddleware`` has known overhead
under load — Majlisna and the FastAPI maintainers both recommend the pure
form).
"""

import re
import time
import uuid
from urllib.parse import parse_qs, urlencode

from loguru import logger
from starlette.responses import JSONResponse
from starlette.types import ASGIApp, Message, Receive, Scope, Send

MAX_URL_PATH_LENGTH = 2048
SLOW_REQUEST_THRESHOLD_MS = 1000

_SCRIPT_TAG_RE = re.compile(r"<script\b[^>]*>.*?</script>", re.IGNORECASE | re.DOTALL)
_EVENT_HANDLER_RE = re.compile(r"\bon\w+\s*=", re.IGNORECASE)
_DANGEROUS_PROTOCOL_RE = re.compile(r"(javascript|vbscript|data)\s*:", re.IGNORECASE)
_PATH_TRAVERSAL_RE = re.compile(r"\.\./|\.\.\\")


def _sanitize_value(value: str) -> str:
    """Strip script tags, event handlers, dangerous protocols, path traversal."""
    value = _SCRIPT_TAG_RE.sub("", value)
    value = _EVENT_HANDLER_RE.sub("", value)
    value = _DANGEROUS_PROTOCOL_RE.sub("", value)
    value = _PATH_TRAVERSAL_RE.sub("", value)
    return value


def _sanitize_query_string(raw: str) -> str:
    """Sanitize each value in a ``key=value&key=value`` query string."""
    if not raw:
        return raw
    params = parse_qs(raw, keep_blank_values=True)
    sanitized: dict[str, list[str]] = {}
    for key, values in params.items():
        sanitized[_sanitize_value(key)] = [_sanitize_value(v) for v in values]
    return urlencode(sanitized, doseq=True)


class SecurityMiddleware:
    """Inject security headers and reject obviously hostile requests.

    Headers added on every response:
    - ``X-Content-Type-Options: nosniff``
    - ``X-Frame-Options: DENY``
    - ``X-XSS-Protection: 1; mode=block``
    - ``Strict-Transport-Security`` (when ``is_production=True``)

    Reject reasons:
    - Null bytes in URL → 400.
    - URL path > ``MAX_URL_PATH_LENGTH`` → 414.
    """

    def __init__(self, app: ASGIApp, *, is_production: bool = False) -> None:
        self.app = app
        self.is_production = is_production

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        path = scope.get("path", "")
        if "\x00" in path:
            logger.warning("Rejected request with null byte in URL: {path}", path=path[:100])
            await JSONResponse(status_code=400, content={"error": "Invalid request"})(scope, receive, send)
            return
        if len(path) > MAX_URL_PATH_LENGTH:
            logger.warning("Rejected overlong URL path ({n} chars)", n=len(path))
            await JSONResponse(status_code=414, content={"error": "URI too long"})(scope, receive, send)
            return

        raw_qs = scope.get("query_string", b"")
        if raw_qs:
            decoded = raw_qs.decode("utf-8", errors="replace")
            cleaned = _sanitize_query_string(decoded)
            if cleaned != decoded:
                scope["query_string"] = cleaned.encode("utf-8")

        async def send_with_headers(message: Message) -> None:
            if message["type"] == "http.response.start":
                headers = list(message.get("headers", []))
                headers.append((b"x-content-type-options", b"nosniff"))
                headers.append((b"x-frame-options", b"DENY"))
                headers.append((b"x-xss-protection", b"1; mode=block"))
                if self.is_production:
                    headers.append((b"strict-transport-security", b"max-age=31536000; includeSubDomains"))
                message["headers"] = headers
            await send(message)

        await self.app(scope, receive, send_with_headers)


class RequestIDMiddleware:
    """Stamp every request with an ``X-Request-ID`` header.

    Honours an inbound ``X-Request-ID`` from a CDN / load balancer or
    generates a fresh hex UUID4. The id is also stashed in ``scope.state``
    so :class:`LoggingMiddleware` can correlate the per-response log line.
    """

    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        headers = dict(scope.get("headers", []))
        inbound = headers.get(b"x-request-id", b"").decode("ascii", errors="replace") or uuid.uuid4().hex
        scope.setdefault("state", {})["request_id"] = inbound

        async def send_with_id(message: Message) -> None:
            if message["type"] == "http.response.start":
                hdrs = list(message.get("headers", []))
                hdrs.append((b"x-request-id", inbound.encode("ascii")))
                message["headers"] = hdrs
            await send(message)

        await self.app(scope, receive, send_with_id)


class LoggingMiddleware:
    """One structured loguru line per HTTP request, plus a slow-request warning."""

    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request_id = scope.get("state", {}).get("request_id", "unknown")
        path = scope.get("path", "")
        method = scope.get("method", "")
        client = scope.get("client")
        client_ip = client[0] if client else "unknown"

        start = time.perf_counter()
        status_code = 500

        async def send_capturing_status(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message.get("status", 500)
            await send(message)

        try:
            await self.app(scope, receive, send_capturing_status)
        except Exception:
            duration_ms = round((time.perf_counter() - start) * 1000, 2)
            logger.bind(
                request_id=request_id,
                method=method,
                path=path,
                duration_ms=duration_ms,
            ).exception("http_request_failed")
            raise

        duration_ms = round((time.perf_counter() - start) * 1000, 2)
        logger.bind(
            request_id=request_id,
            method=method,
            path=path,
            status=status_code,
            duration_ms=duration_ms,
            client_ip=client_ip,
        ).info("http_request")
        if duration_ms > SLOW_REQUEST_THRESHOLD_MS:
            logger.bind(
                request_id=request_id,
                method=method,
                path=path,
                duration_ms=duration_ms,
            ).warning("slow_request")
