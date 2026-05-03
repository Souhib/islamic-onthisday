"""Cross-reference unverified bulk imports against Wikidata + Wikipedia.

Run after ``pipeline.build --include-bulk`` to promote events that have a
real Wikipedia article + matching dates from ``unverified`` to
``auto_verified``, and drop those that don't survive the cross-reference.

    uv run python -m pipeline.verify

What this does, per event with ``verification_status=='unverified'``:

1. **No ``wikidata_qid``** (e.g. OpenITI-only entries) → drop. We have no
   stable cross-reference handle.
2. **Has ``wikidata_qid``** → fetch the Wikidata entity. If it has no
   ``enwiki`` sitelink → drop (the entity isn't notable enough to have a
   Wikipedia article).
3. **Has Wikipedia article** → fetch the article summary. Compare the
   Wikidata ``P570`` death date (or ``P585`` event date) with our stored
   ``canonical_hijri_year`` after Gregorian→Hijri conversion. Within ±3
   Hijri years counts as a match.
4. **Match** → promote to ``auto_verified``, write:
      - ``title_en`` ← Wikidata enwiki label
      - ``title_ar`` ← Wikidata ar label (when available)
      - ``title_fr`` ← Wikidata fr label (when available)
      - ``description_en`` ← Wikipedia REST API extract (first paragraph)
      - ``source_url`` ← canonical Wikipedia article URL
5. **Mismatch** → drop the entry.

Network-bound; uses a small thread pool to keep the round-trip count down.
Wikipedia and Wikidata APIs are public and rate-friendly; we throttle to
~8 concurrent requests as a courtesy.

The script is idempotent: running it again only touches still-unverified
events. It never demotes a manually curated entry.
"""

import argparse
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import date

import httpx
from convertdate import islamic
from rich.console import Console
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeElapsedColumn,
)
from sqlmodel import Session, select

from pipeline.database import session_scope
from pipeline.models.db import Event

console = Console()

WIKIDATA_ENTITY_URL = "https://www.wikidata.org/wiki/Special:EntityData/{qid}.json"
WIKIPEDIA_SUMMARY_URL = "https://{lang}.wikipedia.org/api/rest_v1/page/summary/{title}"
USER_AGENT = "iotd-pipeline-verify/1.0 (https://github.com/souhib/islamic-onthisday)"

# When comparing our stored Hijri year with Wikidata's death-year (after
# converting Wikidata's Gregorian to Hijri), allow ±10 years of slack.
# OpenITI's dates are often year-precision derived from classical biographical
# dictionaries with their own sourcing variance; Wikidata's may come from
# different Western reference works. ±10 captures honest scholarly disagreement
# without admitting outright wrong matches (which usually differ by decades).
HIJRI_TOLERANCE_YEARS: int = 10

# Max concurrent HTTP requests against Wikidata + Wikipedia. Wikipedia's
# REST API tolerates ~200 req/s but Wikidata's Special:EntityData endpoint
# throttles much sooner. Keep concurrency modest.
HTTP_PARALLELISM: int = 4

# Per-request retry budget. Wikidata transiently 429s on bulk runs; an
# exponential backoff usually clears them.
MAX_RETRIES: int = 4


@dataclass
class WikidataInfo:
    """Slim projection of a Wikidata entity for our verification needs."""

    qid: str
    label_en: str | None
    label_ar: str | None
    label_fr: str | None
    description_en: str | None  # short Wikidata description (~1 line)
    description_ar: str | None
    description_fr: str | None
    enwiki_title: str | None
    arwiki_title: str | None
    frwiki_title: str | None
    death_gregorian: date | None  # extracted from P570 if present


@dataclass
class WikipediaSummary:
    """Trimmed Wikipedia REST-API summary."""

    title: str
    extract: str  # plain-text first paragraph(s)
    url: str


@dataclass
class Decision:
    """Outcome of one event's verification pass."""

    slug: str
    action: str  # "promote" | "drop"
    reason: str
    new_title_en: str | None = None
    new_title_ar: str | None = None
    new_title_fr: str | None = None
    new_description_en: str | None = None
    new_description_ar: str | None = None
    new_description_fr: str | None = None
    new_source_url: str | None = None


def _build_client() -> httpx.Client:
    """Build the shared HTTP client with our user-agent + sane timeouts.

    Returns:
        A configured ``httpx.Client`` ready for parallel use.
    """
    return httpx.Client(
        headers={"User-Agent": USER_AGENT, "Accept": "application/json"},
        timeout=15.0,
        follow_redirects=True,
    )


def _get_with_retry(client: httpx.Client, url: str) -> httpx.Response | None:
    """GET with exponential backoff on transient errors.

    Wikidata + Wikipedia both 429 under load. Retries on 429/503/5xx and
    network errors with progressively longer waits. Returns ``None`` only
    when retries are exhausted.

    Args:
        client: The shared HTTP client.
        url: Target URL.

    Returns:
        The successful response, or ``None`` if all retries failed.
    """
    for attempt in range(MAX_RETRIES):
        try:
            response = client.get(url)
            if response.status_code == 200:
                return response
            if response.status_code in (429, 503) or response.status_code >= 500:
                time.sleep(0.5 * (2**attempt))
                continue
            return None
        except httpx.HTTPError:
            time.sleep(0.5 * (2**attempt))
    return None


def _fetch_wikidata(client: httpx.Client, qid: str) -> WikidataInfo | None:
    """Pull the labels + sitelinks + death date for a Wikidata QID.

    Args:
        client: The shared HTTP client.
        qid: Wikidata Q-identifier (e.g. ``"Q12345"``).

    Returns:
        A populated ``WikidataInfo`` or ``None`` when the entity does not
        exist / has been redirected to a non-item / all retries failed.
    """
    response = _get_with_retry(client, WIKIDATA_ENTITY_URL.format(qid=qid))
    if response is None:
        return None
    try:
        data = response.json()
    except ValueError:
        return None
    entities = data.get("entities", {})
    if qid not in entities:
        return None
    entity = entities[qid]
    if entity.get("type") != "item":
        return None

    labels = entity.get("labels", {})
    descriptions = entity.get("descriptions", {})
    sitelinks = entity.get("sitelinks", {})
    claims = entity.get("claims", {})

    return WikidataInfo(
        qid=qid,
        label_en=(labels.get("en") or {}).get("value"),
        label_ar=(labels.get("ar") or {}).get("value"),
        label_fr=(labels.get("fr") or {}).get("value"),
        description_en=(descriptions.get("en") or {}).get("value"),
        description_ar=(descriptions.get("ar") or {}).get("value"),
        description_fr=(descriptions.get("fr") or {}).get("value"),
        enwiki_title=(sitelinks.get("enwiki") or {}).get("title"),
        arwiki_title=(sitelinks.get("arwiki") or {}).get("title"),
        frwiki_title=(sitelinks.get("frwiki") or {}).get("title"),
        death_gregorian=_extract_death_date(claims),
    )


def _extract_death_date(claims: dict) -> date | None:
    """Pull the (proleptic Gregorian) death date from a Wikidata ``P570`` claim.

    Args:
        claims: The ``claims`` dict from a Wikidata entity.

    Returns:
        A ``datetime.date`` (year-precision is enough — month/day fall back
        to 1) or ``None`` when no usable date is present.
    """
    p570 = claims.get("P570")
    if not p570:
        return None
    for stmt in p570:
        snak = stmt.get("mainsnak", {})
        datavalue = snak.get("datavalue", {})
        value = datavalue.get("value", {})
        time_str = value.get("time")  # e.g. "+0923-02-17T00:00:00Z"
        if not time_str:
            continue
        # Wikidata signs years explicitly; strip the leading "+" and split.
        try:
            iso = time_str.lstrip("+")
            # iso form is "YYYY-MM-DDTHH:MM:SSZ"; we only need the date part.
            date_part, _ = iso.split("T", 1)
            year_str, month_str, day_str = date_part.split("-")
            year = int(year_str)
            month = max(1, int(month_str))
            day = max(1, int(day_str))
            return date(year, month, day)
        except (ValueError, AttributeError):
            continue
    return None


def _fetch_wikipedia_summary(client: httpx.Client, lang: str, title: str) -> WikipediaSummary | None:
    """Fetch the REST-API summary for a Wikipedia article.

    Args:
        client: The shared HTTP client.
        lang: Wikipedia language code (e.g. ``"en"``, ``"ar"``).
        title: Article title as returned in the Wikidata sitelinks.

    Returns:
        A ``WikipediaSummary`` or ``None`` on any failure.
    """
    safe_title = title.replace(" ", "_")
    response = _get_with_retry(client, WIKIPEDIA_SUMMARY_URL.format(lang=lang, title=safe_title))
    if response is None:
        return None
    try:
        data = response.json()
    except ValueError:
        return None
    extract = (data.get("extract") or "").strip()
    if not extract:
        return None
    page_url = (data.get("content_urls") or {}).get("desktop", {}).get("page")
    if not page_url:
        page_url = f"https://{lang}.wikipedia.org/wiki/{safe_title}"
    return WikipediaSummary(
        title=data.get("displaytitle") or data.get("title") or title,
        extract=extract,
        url=page_url,
    )


def _pick_summary(client: httpx.Client, wd: WikidataInfo) -> tuple[WikipediaSummary | None, str | None]:
    """Pick the best available Wikipedia summary for ``wd``.

    Tries ``enwiki`` first, then ``arwiki``, then ``frwiki``. Returns the
    summary plus the language code so callers know which language they got.

    Args:
        client: The shared HTTP client.
        wd: The hydrated Wikidata entity.

    Returns:
        ``(summary, lang_code)`` or ``(None, None)`` when no Wikipedia
        article is reachable.
    """
    candidates: list[tuple[str, str | None]] = [
        ("en", wd.enwiki_title),
        ("ar", wd.arwiki_title),
        ("fr", wd.frwiki_title),
    ]
    for lang, title in candidates:
        if not title:
            continue
        summary = _fetch_wikipedia_summary(client, lang, title)
        if summary is not None:
            return summary, lang
    return None, None


def _hijri_year_from_gregorian(when: date) -> int:
    """Convert a Gregorian date to its Hijri year (tabular conversion).

    Args:
        when: The proleptic-Gregorian date to convert.

    Returns:
        The Hijri year (positive integer).
    """
    hijri_year, _, _ = islamic.from_gregorian(when.year, when.month, when.day)
    return int(hijri_year)


def _decide(event: Event, client: httpx.Client) -> Decision:
    """Run the verification pipeline for one event and return a ``Decision``.

    Args:
        event: The unverified event to check.
        client: The shared HTTP client.

    Returns:
        A ``Decision`` describing what to do.
    """
    if not event.wikidata_qid:
        return Decision(slug=event.slug, action="drop", reason="no wikidata_qid (OpenITI-only)")

    wd = _fetch_wikidata(client, event.wikidata_qid)
    if wd is None:
        return Decision(slug=event.slug, action="drop", reason=f"wikidata entity {event.wikidata_qid!r} not fetchable")

    # Accept any major Wikipedia (en > ar > fr). Plenty of Persian / Andalusi /
    # Ottoman figures only have arwiki or frwiki articles — they're still
    # notable, just not in the English-language press.
    summary, summary_lang = _pick_summary(client, wd)
    if summary is None:
        return Decision(slug=event.slug, action="drop", reason="no Wikipedia article in en/ar/fr")

    # Date check: Wikidata P570 must agree with our stored hijri year (±3).
    if event.canonical_hijri_year and wd.death_gregorian:
        wd_hijri = _hijri_year_from_gregorian(wd.death_gregorian)
        delta = abs(wd_hijri - event.canonical_hijri_year)
        if delta > HIJRI_TOLERANCE_YEARS:
            return Decision(
                slug=event.slug,
                action="drop",
                reason=(f"hijri year mismatch: stored={event.canonical_hijri_year}, wikidata={wd_hijri} (Δ={delta})"),
            )

    # Route the description to the right language slot. When the only
    # available Wikipedia is Arabic, ``description_ar`` carries the full text;
    # ``description_en`` falls back to Wikidata's short English description
    # (one line) so the English UI still shows *something*.
    descriptions = {"en": None, "ar": None, "fr": None}
    descriptions[summary_lang] = summary.extract
    # English fallback for non-en summaries: Wikidata short description.
    if summary_lang != "en" and wd.description_en:
        descriptions["en"] = wd.description_en

    return Decision(
        slug=event.slug,
        action="promote",
        reason=f"wikipedia[{summary_lang}] + dates match",
        new_title_en=wd.label_en or summary.title or event.title_en,
        new_title_ar=wd.label_ar,
        new_title_fr=wd.label_fr,
        new_description_en=descriptions["en"],
        new_description_ar=descriptions["ar"],
        new_description_fr=descriptions["fr"],
        new_source_url=summary.url,
    )


def _apply_decision(session: Session, event: Event, decision: Decision) -> None:
    """Persist the decision for one event.

    Args:
        session: Open SQLModel session.
        event: The event row.
        decision: The verification outcome.
    """
    if decision.action == "drop":
        session.delete(event)
        return
    if decision.action == "promote":
        if decision.new_title_en:
            event.title_en = decision.new_title_en
        if decision.new_title_ar and not event.title_ar:
            event.title_ar = decision.new_title_ar
        if decision.new_title_fr and not event.title_fr:
            event.title_fr = decision.new_title_fr
        if decision.new_description_en:
            event.description_en = decision.new_description_en
        if decision.new_description_ar and not event.description_ar:
            event.description_ar = decision.new_description_ar
        if decision.new_description_fr and not event.description_fr:
            event.description_fr = decision.new_description_fr
        if decision.new_source_url:
            event.source_url = decision.new_source_url
        event.verification_status = "auto_verified"
        session.add(event)


def _candidates(session: Session) -> list[Event]:
    """Return every event still flagged ``unverified``.

    Args:
        session: Open SQLModel session.

    Returns:
        A list of events to verify (already detached from the session is OK
        — we re-fetch by slug when applying the decision).
    """
    return list(session.exec(select(Event).where(Event.verification_status == "unverified")))


def _lookup_slug(slug: str, client: httpx.Client) -> tuple[str, Decision]:
    """Re-load by slug + run the cross-reference."""
    with session_scope() as inner_session:
        event = inner_session.exec(select(Event).where(Event.slug == slug)).first()
        if event is None:
            return slug, Decision(slug=slug, action="drop", reason="event missing during pass")
        return slug, _decide(event, client)


def _collect_decisions(slugs: list[str]) -> dict[str, Decision]:
    """Fan out HTTP lookups across a thread pool, return a slug → Decision map."""
    decisions: dict[str, Decision] = {}
    progress = Progress(
        SpinnerColumn(),
        TextColumn("{task.description}"),
        BarColumn(),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
    )
    with progress:
        task_id = progress.add_task("verify", total=len(slugs))
        with _build_client() as client, ThreadPoolExecutor(max_workers=HTTP_PARALLELISM) as pool:
            futures = {pool.submit(_lookup_slug, slug, client): slug for slug in slugs}
            for future in as_completed(futures):
                slug, decision = future.result()
                decisions[slug] = decision
                progress.update(task_id, advance=1)
    return decisions


def _apply_decisions(slugs: list[str], decisions: dict[str, Decision]) -> tuple[int, int, dict[str, int]]:
    """Apply decisions in a single session; return (promoted, dropped, reason_histogram)."""
    promoted = 0
    dropped = 0
    drop_reasons: dict[str, int] = {}
    with session_scope() as session:
        for slug in slugs:
            decision = decisions.get(slug)
            if decision is None:
                continue
            event = session.exec(select(Event).where(Event.slug == slug)).first()
            if event is None:
                continue
            _apply_decision(session, event, decision)
            if decision.action == "promote":
                promoted += 1
            else:
                dropped += 1
                key = decision.reason.split(":", 1)[0]
                drop_reasons[key] = drop_reasons.get(key, 0) + 1
    return promoted, dropped, drop_reasons


def _print_summary(promoted: int, dropped: int, drop_reasons: dict[str, int]) -> None:
    """Render the final tally for the operator."""
    console.print()
    console.print(f"[green]Promoted to auto_verified:[/] {promoted}")
    console.print(f"[red]Dropped:[/] {dropped}")
    if drop_reasons:
        console.print("[bold]Drop reasons:[/]")
        for reason, count in sorted(drop_reasons.items(), key=lambda kv: -kv[1]):
            console.print(f"  {count:>5}  {reason}")


def main() -> None:
    """CLI entry: iterate unverified events and promote / drop each."""
    parser = argparse.ArgumentParser(description="Cross-reference bulk imports against Wikidata + Wikipedia.")
    parser.add_argument("--limit", type=int, default=None, help="Max events to process (default: all)")
    parser.add_argument("--dry-run", action="store_true", help="Print decisions without writing them")
    args = parser.parse_args()

    with session_scope() as session:
        events = _candidates(session)
        if args.limit:
            events = events[: args.limit]
        slugs = [e.slug for e in events]

    total = len(slugs)
    if total == 0:
        console.print("[green]No unverified events to process. Done.[/]")
        return

    console.print(f"[bold]Processing {total} unverified events…[/]")
    decisions = _collect_decisions(slugs)

    if args.dry_run:
        for slug, decision in decisions.items():
            console.print(f"  {decision.action:8s} {slug}: {decision.reason}")
        console.print("[yellow]dry-run, no writes performed[/]")
        return

    promoted, dropped, drop_reasons = _apply_decisions(slugs, decisions)
    _print_summary(promoted, dropped, drop_reasons)


if __name__ == "__main__":
    main()
