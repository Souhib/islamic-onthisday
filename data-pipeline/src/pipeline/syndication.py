"""Generate sitemap.xml + robots.txt + feed.xml directly into ``web/public/``.

Why the pipeline owns this and not the backend:

The dataset only changes when the pipeline rebuilds. Every URL on the site
is deterministic from the contents of the SQLite — there's no dynamic
content the backend would need to compute on every request. So we generate
the syndication files at build time and ship them as static assets served
by the FE host (Vercel / Cloudflare / nginx). The backend stays 100 %
private — only the FE origin sees public traffic, which matches the
project's deployment posture.

Files emitted (always to ``<repo>/web/public/``):

- ``robots.txt`` — points crawlers at ``sitemap.xml`` and blocks AI
  scrapers (the same blocklist Souhib uses on LaTabdhir).
- ``sitemap.xml`` — every public URL with a ``<lastmod>``. Events have a
  real ``updated_at``; the others fall back to the build timestamp.
- ``feed.xml`` — Atom 1.0 of the headline picked for each of the last 14
  calendar days. Mirrors what ``/api/v1/recent`` returns: events first,
  lessons as fallback when no event matches the day.

Called as the final step of ``pipeline.build`` (step 6); the FE
Dockerfile's ``pipeline`` stage runs the full build so these files are
baked into the nginx image alongside the SPA. The daily Dokploy redeploy
rebuilds the FE image to roll the feed forward.
"""

import os
import random
from datetime import UTC, date, datetime, timedelta
from pathlib import Path
from xml.sax.saxutils import escape as _xml_escape

from convertdate import islamic
from rich.console import Console
from sqlalchemy import or_
from sqlmodel import Session, select

from pipeline.constants import PROJECT_ROOT
from pipeline.database import session_scope
from pipeline.models.db import DatelessLesson, Event, Observance, Person

# ---------------------------------------------------------------------------
# Config — single source of truth for paths + tuning knobs.
# ---------------------------------------------------------------------------

DEFAULT_OUTPUT_DIR: Path = PROJECT_ROOT.parent / "web" / "public"
DEFAULT_FRONTEND_URL: str = "http://localhost:3000"

# How many days the Atom feed covers. Same number ``RecentController`` uses
# so a power user reading both the feed and the recent page sees the same
# rotation.
FEED_DAYS: int = 14

# Headline picker — must mirror the backend's ``HEADLINE_*`` constants.
_HEADLINE_IMPORTANCE: tuple[str, ...] = ("major", "notable")
_HEADLINE_VERIFICATION_STATUSES: frozenset[str] = frozenset({"single_source", "cross_verified", "scholar_reviewed"})
_HIJRI_MD_FACTOR: int = 100

# AI scrapers we explicitly disallow. Mirrors LaTabdhir's robots.txt — these
# bots have ignored crawl-delays in the past and chewed bandwidth without
# adding any indexing value.
_AI_BOTS: tuple[str, ...] = (
    "GPTBot",
    "ChatGPT-User",
    "CCBot",
    "anthropic-ai",
    "Claude-Web",
    "Google-Extended",
    "PerplexityBot",
    "Bytespider",
)


console = Console()


# ---------------------------------------------------------------------------
# Public entry points.
# ---------------------------------------------------------------------------


def syndicate(*, frontend_url: str | None = None, output_dir: Path | None = None) -> None:
    """Regenerate sitemap.xml + robots.txt + feed.xml.

    Args:
        frontend_url: Public origin of the FE (for absolute URLs in the XML).
            Defaults to ``$FRONTEND_URL`` env var or ``http://localhost:3000``.
        output_dir: Where to write the three files. Defaults to
            ``<repo>/web/public/``.
    """
    frontend_url = (frontend_url or os.environ.get("FRONTEND_URL") or DEFAULT_FRONTEND_URL).rstrip("/")
    output_dir = output_dir or DEFAULT_OUTPUT_DIR
    output_dir.mkdir(parents=True, exist_ok=True)

    with session_scope() as session:
        sitemap_xml = _build_sitemap(session, frontend_url=frontend_url)
        feed_xml = _build_feed(session, frontend_url=frontend_url)

    robots_txt = _build_robots(frontend_url=frontend_url)

    (output_dir / "sitemap.xml").write_text(sitemap_xml, encoding="utf-8")
    (output_dir / "robots.txt").write_text(robots_txt, encoding="utf-8")
    (output_dir / "feed.xml").write_text(feed_xml, encoding="utf-8")
    console.log(
        f"  syndication: wrote sitemap.xml + robots.txt + feed.xml to {output_dir}",
    )


# ---------------------------------------------------------------------------
# Sitemap.
# ---------------------------------------------------------------------------


def _build_sitemap(session: Session, *, frontend_url: str) -> str:
    """Return the sitemap.xml document body."""
    now = datetime.now(UTC)
    urls: list[tuple[str, datetime, str]] = []

    # Static landings.
    for path, freq in (
        ("", "daily"),
        ("/browse", "weekly"),
        ("/observances", "monthly"),
        ("/recent", "daily"),
    ):
        urls.append((f"{frontend_url}{path}", now, freq))

    for slug, updated_at in session.exec(select(Event.slug, Event.updated_at)).all():
        urls.append((f"{frontend_url}/events/{slug}", updated_at, "monthly"))
    for slug in session.exec(select(DatelessLesson.slug)).all():
        urls.append((f"{frontend_url}/lessons/{slug}", now, "monthly"))
    for slug in session.exec(select(Observance.slug)).all():
        urls.append((f"{frontend_url}/observances/{slug}", now, "yearly"))
    for slug in session.exec(select(Person.slug)).all():
        urls.append((f"{frontend_url}/people/{slug}", now, "yearly"))

    return _render_sitemap(urls)


def _render_sitemap(urls: list[tuple[str, datetime, str]]) -> str:
    parts = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ]
    for loc, lastmod, changefreq in urls:
        parts.append("  <url>")
        parts.append(f"    <loc>{_xml_escape(loc)}</loc>")
        parts.append(f"    <lastmod>{lastmod.date().isoformat()}</lastmod>")
        parts.append(f"    <changefreq>{changefreq}</changefreq>")
        parts.append("  </url>")
    parts.append("</urlset>\n")
    return "\n".join(parts)


# ---------------------------------------------------------------------------
# Robots.
# ---------------------------------------------------------------------------


def _build_robots(*, frontend_url: str) -> str:
    """Return robots.txt that points to the sitemap and blocks AI scrapers."""
    lines: list[str] = [
        "# Thaqafa",
        "# Robots policy for search engines",
        "",
        "User-agent: *",
        "Allow: /",
        "Crawl-delay: 1",
        "",
        f"Sitemap: {frontend_url}/sitemap.xml",
        "",
        "# AI scrapers — denied (high bandwidth, low indexing value).",
    ]
    for bot in _AI_BOTS:
        lines.append(f"User-agent: {bot}")
        lines.append("Disallow: /")
        lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Atom feed — last N days of "what was on /today".
# ---------------------------------------------------------------------------


def _build_feed(session: Session, *, frontend_url: str) -> str:
    """Return the Atom 1.0 feed body for the last ``FEED_DAYS`` days."""
    today_utc = datetime.now(UTC).date()
    dates = [today_utc - timedelta(days=i) for i in range(FEED_DAYS)]

    headlines = _pick_headlines_for_dates(session, dates)
    missing = [d for d in dates if d not in headlines]
    lesson_fallbacks = _pick_lesson_fallbacks_for_dates(session, missing) if missing else {}

    items: list[_FeedItem] = []
    for d in dates:
        if event := headlines.get(d):
            items.append(_event_feed_item(event, d, today_utc, frontend_url=frontend_url))
        elif lesson := lesson_fallbacks.get(d):
            items.append(_lesson_feed_item(lesson, d, today_utc, frontend_url=frontend_url))

    return _render_atom(items, frontend_url=frontend_url)


def _pick_headlines_for_dates(session: Session, dates: list[date]) -> dict[date, Event]:
    """Mirror of ``RecentController._pick_headlines`` — sync edition.

    One query per importance tier. Within a tier, the first matching event
    wins for each date. Hijri / Gregorian DOY indexes mean SQLite handles
    the lookup without a sort.
    """
    doys = {d: d.timetuple().tm_yday for d in dates}
    md_keys: dict[date, int] = {}
    for d in dates:
        _, hm, hd = islamic.from_gregorian(d.year, d.month, d.day)
        md_keys[d] = hm * _HIJRI_MD_FACTOR + hd
    all_doys = list(doys.values())
    all_md_keys = list(md_keys.values())

    result: dict[date, Event] = {}
    for importance in _HEADLINE_IMPORTANCE:
        stmt = (
            select(Event)
            .where(
                or_(
                    Event.display_gregorian_doy.in_(all_doys),
                    Event.display_hijri_md_key.in_(all_md_keys),
                ),
                Event.importance == importance,
                Event.verification_status.in_(_HEADLINE_VERIFICATION_STATUSES),
            )
            .order_by(Event.verified.desc(), Event.canonical_gregorian_date.desc())
        )
        rows = session.exec(stmt).all()
        for d in dates:
            if d in result:
                continue
            doy = doys[d]
            md = md_keys[d]
            for ev in rows:
                if ev.display_gregorian_doy == doy or ev.display_hijri_md_key == md:
                    result[d] = ev
                    break
    return result


def _pick_lesson_fallbacks_for_dates(session: Session, missing_dates: list[date]) -> dict[date, DatelessLesson]:
    """Mirror of ``RecentController._pick_lesson_fallbacks`` — sync edition.

    Fetches every lesson once and partitions in Python: first by DOY match,
    then by global pool when the DOY pool is empty for a date.
    """
    if not missing_dates:
        return {}
    doys = {d.timetuple().tm_yday for d in missing_dates}

    rows = session.exec(select(DatelessLesson)).all()
    day_pools: dict[int, list[DatelessLesson]] = {}
    global_pool: list[DatelessLesson] = []
    for lesson in rows:
        if lesson.display_day_of_year in doys:
            day_pools.setdefault(lesson.display_day_of_year, []).append(lesson)
        else:
            global_pool.append(lesson)

    result: dict[date, DatelessLesson] = {}
    for d in missing_dates:
        doy = d.timetuple().tm_yday
        pool = list(day_pools.get(doy, []))
        random.Random(f"{d.year}:{doy}").shuffle(pool)
        if pool:
            result[d] = pool[0]
            continue
        backfill = list(global_pool)
        random.Random(f"{d.year}:{doy}:global").shuffle(backfill)
        if backfill:
            result[d] = backfill[0]
    return result


class _FeedItem:
    """Internal item shape — flat enough that ``_render_atom`` stays trivial."""

    __slots__ = ("title", "url", "published", "updated", "summary")

    def __init__(self, *, title: str, url: str, published: str, updated: str, summary: str):
        self.title = title
        self.url = url
        self.published = published
        self.updated = updated
        self.summary = summary


def _event_feed_item(event: Event, calendar_day: date, today_utc: date, *, frontend_url: str) -> _FeedItem:
    surfaced = _atom_timestamp(calendar_day)
    updated = datetime.now(UTC).isoformat(timespec="seconds") if calendar_day == today_utc else surfaced
    summary = (event.description_en or "").split("\n\n")[0][:480]
    return _FeedItem(
        title=event.title_en,
        url=f"{frontend_url}/events/{event.slug}",
        published=surfaced,
        updated=updated,
        summary=summary,
    )


def _lesson_feed_item(lesson: DatelessLesson, calendar_day: date, today_utc: date, *, frontend_url: str) -> _FeedItem:
    surfaced = _atom_timestamp(calendar_day)
    updated = datetime.now(UTC).isoformat(timespec="seconds") if calendar_day == today_utc else surfaced
    summary = (lesson.description_en or "").split("\n\n")[0][:480]
    return _FeedItem(
        title=lesson.title_en,
        url=f"{frontend_url}/lessons/{lesson.slug}",
        published=surfaced,
        updated=updated,
        summary=summary,
    )


def _atom_timestamp(d: date) -> str:
    return datetime(d.year, d.month, d.day, tzinfo=UTC).isoformat(timespec="seconds")


def _render_atom(items: list[_FeedItem], *, frontend_url: str) -> str:
    now_iso = datetime.now(UTC).isoformat(timespec="seconds")
    self_link = f"{frontend_url}/feed.xml"
    home_link = f"{frontend_url}/"
    parts = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<feed xmlns="http://www.w3.org/2005/Atom">',
        "  <title>Thaqafa</title>",
        f'  <link href={_quote_attr(self_link)} rel="self" />',
        f"  <link href={_quote_attr(home_link)} />",
        f"  <id>{_xml_escape(home_link)}</id>",
        f"  <updated>{now_iso}</updated>",
        "  <subtitle>One verified Islamic-history event per day.</subtitle>",
    ]
    for item in items:
        parts.append("  <entry>")
        parts.append(f"    <title>{_xml_escape(item.title)}</title>")
        parts.append(f"    <link href={_quote_attr(item.url)} />")
        parts.append(f"    <id>{_xml_escape(item.url)}</id>")
        parts.append(f"    <published>{item.published}</published>")
        parts.append(f"    <updated>{item.updated}</updated>")
        parts.append(f"    <summary>{_xml_escape(item.summary)}</summary>")
        parts.append("  </entry>")
    parts.append("</feed>\n")
    return "\n".join(parts)


def _quote_attr(value: str) -> str:
    """Quote a value for use as an XML attribute (escapes ``&<>"``)."""
    return f'"{_xml_escape(value, {chr(34): "&quot;"})}"'
