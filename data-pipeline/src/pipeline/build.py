"""Orchestrator. Rebuilds the SQLite database from scratch.

Usage:  uv run python -m pipeline.build

The build is curated-only by design — every entry that ships in the API
has been hand-vetted against the editorial bar (CLAUDE.md). The
discovery scripts in ``data-pipeline/scripts/discovery/`` produce JSON
reports of candidate entries from Wikidata / OpenITI for human review;
they never write to the production SQLite directly.
"""

import argparse
import calendar
from datetime import date, timedelta

from rich.console import Console
from rich.table import Table
from sqlalchemy import func, update
from sqlmodel import Session, select

from pipeline.database import init_db, session_scope
from pipeline.dataset_meta import write_dataset_meta
from pipeline.images.fetcher import fetch_safe_images
from pipeline.ingestion import curated
from pipeline.models.db import DateClaim, DatelessLesson, Event, Person, Source, Tag
from pipeline.quran_extracts import write_quran_extracts
from pipeline.syndication import syndicate

# Canonical majors — the iconic events every Muslim knows, promoted to
# ``importance="major"`` after all ingestion so the headline slot shows them.
CANONICAL_MAJOR_SLUGS: frozenset[str] = frozenset(
    {
        # Prophetic era
        "first-revelation-iqra",
        "hijra-arrival-medina",
        "battle-of-badr",
        "battle-of-uhud",
        "treaty-of-hudaybiyyah",
        "conquest-of-makkah",
        "isra-wal-miraj",
        "farewell-pilgrimage",
        "death-of-the-prophet",
        "death-of-khadija",
        "death-of-fatima-az-zahra",
        "martyrdom-of-sumayya",
        # Rashidun
        "death-of-abu-bakr",
        "death-of-umar",
        "death-of-uthman",
        "death-of-ali",
        "conquest-of-jerusalem-umar",
        "battle-of-yarmouk",
        "battle-of-qadisiyyah",
        "uthmanic-mushaf-standardisation",
        # Umayyad / Karbala
        "karbala",
        "dome-of-the-rock-completed",
        "battle-of-tours",
        # Abbasid scholars
        "death-of-abu-hanifa",
        "death-of-malik",
        "death-of-shafii",
        "death-of-ahmad-ibn-hanbal",
        "death-of-bukhari",
        "death-of-muslim",
        "death-of-tabari",
        "death-of-ghazali",
        # Andalus
        "fall-of-granada",
        "abd-al-rahman-iii-caliphate",
        # Crusades / Saladin
        "first-crusade-fall-of-jerusalem",
        "battle-of-hattin",
        "saladin-conquest-of-jerusalem",
        "death-of-saladin",
        # Mongol / Mamluk
        "sack-of-baghdad",
        "battle-of-ain-jalut",
        # Ottoman / Mughal
        "fall-of-constantinople",
        "battle-of-chaldiran",
        "first-battle-of-panipat",
        # Modern
        "abolition-of-caliphate",
    }
)

console = Console()

_MONTH_NAMES: tuple[str, ...] = (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)


def _count(session: Session, stmt) -> int:
    """Execute a ``select(func.count(...))`` statement and return the scalar int.

    Args:
        session: Open SQLModel session.
        stmt: A SELECT statement wrapping a single ``func.count()`` expression.

    Returns:
        The integer count produced by the statement.
    """
    return int(session.exec(stmt).one())


def _render_summary_table(session: Session) -> None:
    """Render the top-level "Database summary" table.

    Args:
        session: Open SQLModel session.
    """
    total_events = _count(session, select(func.count(Event.id)))
    total_persons = _count(session, select(func.count(Person.id)))
    total_claims = _count(session, select(func.count(DateClaim.id)))
    total_lessons = _count(session, select(func.count(DatelessLesson.id)))
    total_sources = _count(session, select(func.count(Source.id)))
    total_tags = _count(session, select(func.count(Tag.id)))

    tier1 = _count(
        session,
        select(func.count(Event.id)).where(Event.canonical_gregorian_precision == "day"),
    )
    tier2 = _count(
        session,
        select(func.count(Event.id)).where(Event.canonical_gregorian_precision == "month"),
    )
    tier3 = _count(
        session,
        select(func.count(Event.id)).where(
            (Event.canonical_gregorian_precision == "year") | (Event.canonical_gregorian_precision.is_(None))
        ),
    )
    verified_tier1 = _count(
        session,
        select(func.count(Event.id))
        .where(Event.canonical_gregorian_precision == "day")
        .where(Event.verified.is_(True)),
    )

    overview = Table(title="Database summary", show_header=True, header_style="bold")
    overview.add_column("Metric")
    overview.add_column("Value", justify="right")
    overview.add_row("Sources", str(total_sources))
    overview.add_row("Persons", str(total_persons))
    overview.add_row("Events (total)", str(total_events))
    overview.add_row("  — Tier 1 (day-precise)", str(tier1))
    overview.add_row("  — Tier 1 (day-precise, VERIFIED)", str(verified_tier1))
    overview.add_row("  — Tier 2 (month-precise)", str(tier2))
    overview.add_row("  — Tier 3 (year-precise)", str(tier3))
    overview.add_row("Date claims (total)", str(total_claims))
    overview.add_row("Dateless lessons", str(total_lessons))
    overview.add_row("Tags", str(total_tags))
    console.print(overview)


def _render_per_month_table(session: Session) -> None:
    """Render the per-Gregorian-month Tier-1 event counts.

    Args:
        session: Open SQLAlchemy session.
    """
    months = Table(title="Tier-1 events per Gregorian month", show_header=True)
    months.add_column("Month")
    months.add_column("Tier-1 events", justify="right")
    for month in range(1, 13):
        start_doy = date(2024, month, 1).timetuple().tm_yday
        end_day = calendar.monthrange(2024, month)[1]
        end_doy = date(2024, month, end_day).timetuple().tm_yday
        count = _count(
            session,
            select(func.count(Event.id))
            .where(Event.canonical_gregorian_precision == "day")
            .where(Event.display_gregorian_doy.between(start_doy, end_doy)),
        )
        months.add_row(_MONTH_NAMES[month - 1], str(count))
    console.print(months)


def _render_days_and_busiest(session: Session) -> None:
    """Render the "days with ≥1 event" line and the top-10 busiest days table.

    Args:
        session: Open SQLAlchemy session.
    """
    days_with_events = _count(
        session,
        select(func.count(func.distinct(Event.display_gregorian_doy)))
        .where(Event.canonical_gregorian_precision == "day")
        .where(Event.display_gregorian_doy.isnot(None)),
    )
    console.print(f"[bold]Gregorian days with at least one Tier-1 event:[/] {days_with_events}/366")

    busiest = session.exec(
        select(Event.display_gregorian_doy, func.count(Event.id).label("n"))
        .where(Event.canonical_gregorian_precision == "day")
        .where(Event.display_gregorian_doy.isnot(None))
        .group_by(Event.display_gregorian_doy)
        .order_by(func.count(Event.id).desc())
        .limit(10)
    ).all()
    hot = Table(title="Busiest 10 Gregorian days", show_header=True)
    hot.add_column("Day of year")
    hot.add_column("Date (leap-year)")
    hot.add_column("Tier-1 count", justify="right")
    ref = date(2024, 1, 1)
    for doy, count in busiest:
        rendered = ref + timedelta(days=doy - 1)
        hot.add_row(str(doy), rendered.strftime("%b %d"), str(count))
    console.print(hot)


_HIJRI_MONTH_NAMES: tuple[str, ...] = (
    "Muharram",
    "Safar",
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    "Jumada al-Ula",
    "Jumada al-Akhirah",
    "Rajab",
    "Sha'ban",
    "Ramadan",
    "Shawwal",
    "Dhu al-Qa'da",
    "Dhu al-Hijja",
)


def _render_per_hijri_month_table(session: Session) -> None:
    """Render events-per-Hijri-month — the daily-rotation pool sizes.

    Args:
        session: Open SQLModel session.
    """
    months = Table(title="Events per Hijri month (rotation pool)", show_header=True)
    months.add_column("Hijri month")
    months.add_column("All events", justify="right")
    months.add_column("Verified curated", justify="right")
    months.add_column("Day-anniversary", justify="right")
    for hm in range(1, 13):
        total = _count(
            session,
            select(func.count(Event.id)).where(Event.display_hijri_month == hm),
        )
        verified = _count(
            session,
            select(func.count(Event.id)).where(Event.display_hijri_month == hm).where(Event.verified.is_(True)),
        )
        anniversary = _count(
            session,
            select(func.count(Event.id))
            .where(Event.display_hijri_month == hm)
            .where(Event.display_hijri_md_key.isnot(None)),
        )
        months.add_row(_HIJRI_MONTH_NAMES[hm - 1], str(total), str(verified), str(anniversary))
    console.print(months)


def _render_verification_breakdown(session: Session) -> None:
    """Show the verification_status distribution.

    Args:
        session: Open SQLModel session.
    """
    table = Table(title="Verification status distribution", show_header=True)
    table.add_column("Status")
    table.add_column("Count", justify="right")
    rows = session.exec(
        select(Event.verification_status, func.count(Event.id))
        .group_by(Event.verification_status)
        .order_by(func.count(Event.id).desc())
    ).all()
    for status, count in rows:
        table.add_row(status, str(count))
    console.print(table)


def _render_coverage_report(session: Session) -> None:
    """Run all sub-reports in sequence.

    Args:
        session: Open SQLModel session.
    """
    _render_summary_table(session)
    _render_per_month_table(session)
    _render_per_hijri_month_table(session)
    _render_verification_breakdown(session)
    _render_days_and_busiest(session)


def build() -> None:
    """Rebuild the pipeline database end-to-end from curated YAML.

    Every entry that lands in the SQLite must come from the
    ``data/curated/*.yaml`` files — i.e. it has been hand-vetted against
    the editorial bar (Sunni framing, classical sources, hadith refs,
    cf. ``CLAUDE.md`` and ``EDITORIAL.md``). Bulk imports from external
    knowledge bases are off the table for the production build; the
    standalone discovery scripts in ``data-pipeline/scripts/discovery/``
    can be run by hand to surface candidate entries as JSON reports the
    curator can then promote into YAML one by one.
    """
    console.rule("[bold cyan]Islamic On-This-Day pipeline")

    console.log("[bold]Step 1: initialising database…")
    init_db()

    console.log("[bold]Step 2: ingesting curated YAML…")
    with session_scope() as session:
        stats = curated.ingest(session)
        console.log(f"  curated: {stats}")

    console.log("[bold]Step 3: enforcing image-safety policy…")
    with session_scope() as session:
        stats = fetch_safe_images(session)
        console.log(f"  image policy: {stats}")

    console.log("[bold]Step 4: promoting canonical majors…")
    with session_scope() as session:
        promoted = _promote_canonical_majors(session)
        console.log(f"  promoted {promoted} events to importance=major")

    console.log("[bold]Step 5: coverage report[/]")
    with session_scope() as session:
        _render_coverage_report(session)

    console.log("[bold]Step 6: regenerating syndication (sitemap.xml + robots.txt + feed.xml)…")
    syndicate()

    console.log("[bold]Step 7: writing dataset-meta.json (footer profundity signal)…")
    meta_path = write_dataset_meta()
    console.log(f"  dataset-meta: wrote {meta_path}")

    console.log("[bold]Step 8: fetching trilingual Qur'an extracts (epigraph + per-event)…")
    extracts_path = write_quran_extracts()
    console.log(f"  quran-extracts: wrote {extracts_path}")

    console.rule("[bold green]Done")


def _promote_canonical_majors(session: Session) -> int:
    """Promote the iconic-event slugs listed in :data:`CANONICAL_MAJOR_SLUGS`.

    Args:
        session: Open SQLModel session.

    Returns:
        The number of event rows updated to ``importance="major"``.
    """
    result = session.exec(update(Event).where(Event.slug.in_(CANONICAL_MAJOR_SLUGS)).values(importance="major"))
    return int(result.rowcount or 0)


def main() -> None:
    """CLI entry point for `python -m pipeline.build`."""
    argparse.ArgumentParser(
        description=(
            "Build the Islamic On-This-Day DB from curated YAML. Bulk discovery "
            "from Wikidata / OpenITI lives under data-pipeline/scripts/discovery/ "
            "and is run by hand — never by this command."
        )
    ).parse_args()
    build()


if __name__ == "__main__":
    main()
