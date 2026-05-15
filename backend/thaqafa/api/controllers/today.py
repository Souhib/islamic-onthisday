"""Today controller — picks the headline event + supporting rails for a date.

Projection helpers live in :mod:`thaqafa.api.services.projections`; this
controller is the *picker* — it chooses which rows to render, then hands
them off to be projected.
"""

import random
from datetime import UTC, date, datetime

from pipeline.models.db import DateClaim, DatelessLesson, Event, EventPerson, Observance
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.constants import (
    HEADLINE_IMPORTANCE,
    HEADLINE_VERIFICATION_STATUSES,
    HIJRI_MD_FACTOR,
    TODAY_SECONDARY_LIMIT,
)
from thaqafa.api.schemas.today import AnyDetail, AnySummary, TodayCalendar, TodayResponse
from thaqafa.api.services.calendar import calendar_for, hijri_month_index, project_observance_ref
from thaqafa.api.services.projections import (
    project_event_detail,
    project_event_summary,
    project_lesson_detail,
    project_lesson_summary,
)


class TodayController:
    """Picks the headline event and supporting rails for a calendar day."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def today(self, today: date | None = None) -> TodayResponse:
        """Build the full ``/api/v1/today`` payload for ``today`` (or now UTC)."""
        today = today or datetime.now(UTC).date()
        calendar = calendar_for(today)
        year = today.year
        doy = today.timetuple().tm_yday

        headline_event = await self._pick_headline(today, calendar)
        secondary_events = await self._pick_secondary(
            today, calendar, exclude_slug=headline_event.slug if headline_event else None
        )
        lessons = await self._pick_lessons(doy, year, limit=TODAY_SECONDARY_LIMIT)
        observance = await self._pick_observance(calendar.hijri.day, hijri_month_index(calendar.hijri.month))

        headline: AnyDetail | None = None
        if headline_event is not None:
            headline = project_event_detail(headline_event)
        elif lessons:
            headline = project_lesson_detail(lessons[0])
            lessons = lessons[1:]

        secondaries: list[AnySummary] = []
        event_iter = iter(secondary_events)
        lesson_iter = iter(lessons)
        while len(secondaries) < TODAY_SECONDARY_LIMIT:
            event = next(event_iter, None)
            lesson = next(lesson_iter, None)
            if event is None and lesson is None:
                break
            if event is not None:
                secondaries.append(project_event_summary(event))
                if len(secondaries) >= TODAY_SECONDARY_LIMIT:
                    break
            if lesson is not None:
                secondaries.append(project_lesson_summary(lesson))

        return TodayResponse(
            today=calendar,
            headline=headline,
            secondary=secondaries,
            observance=project_observance_ref(observance) if observance else None,
        )

    async def _pick_headline(self, today: date, calendar: TodayCalendar) -> Event | None:
        """Walk the importance ladder to find a curated headline for the day."""
        greg_md_key = today.month * 100 + today.day
        hijri_month = hijri_month_index(calendar.hijri.month)
        md_key = hijri_month * HIJRI_MD_FACTOR + calendar.hijri.day

        for importance in HEADLINE_IMPORTANCE:
            stmt = (
                select(Event)
                .where(
                    (Event.display_gregorian_md_key == greg_md_key) | (Event.display_hijri_md_key == md_key),
                    Event.importance == importance,
                    Event.verification_status.in_(HEADLINE_VERIFICATION_STATUSES),
                )
                .options(
                    selectinload(Event.claims).selectinload(DateClaim.source),
                    selectinload(Event.people_links).selectinload(EventPerson.person),
                )
                .order_by(Event.verified.desc(), Event.canonical_gregorian_date.desc())
                .limit(1)
            )
            result = await self.session.exec(stmt)
            row = result.first()
            if row is not None:
                return row[0]
        return None

    async def _pick_secondary(
        self,
        today: date,
        calendar: TodayCalendar,
        *,
        exclude_slug: str | None,
    ) -> list[Event]:
        """Pick the rotation rail of secondary events for the day."""
        greg_md_key = today.month * 100 + today.day
        hijri_month = hijri_month_index(calendar.hijri.month)
        md_key = hijri_month * HIJRI_MD_FACTOR + calendar.hijri.day
        stmt = (
            select(Event)
            .where(
                (Event.display_gregorian_md_key == greg_md_key) | (Event.display_hijri_md_key == md_key),
            )
            .order_by(Event.importance.asc(), Event.canonical_gregorian_date.desc())
            .limit(TODAY_SECONDARY_LIMIT + 1)
        )
        result = await self.session.exec(stmt)
        rows = [row[0] for row in result.all()]
        return [r for r in rows if r.slug != exclude_slug][:TODAY_SECONDARY_LIMIT]

    async def _pick_lessons(self, doy: int, year: int, *, limit: int) -> list[DatelessLesson]:
        """Pick lessons for a day, backfilling from the global pool when needed.

        Day-specific lessons come first (deterministic shuffle keyed by
        ``year:doy`` so the rotation is stable per-user-day). When fewer than
        *limit* exist, the remainder is drawn from other days, shuffled with
        a different seed so each day gets a distinct rotation.
        """
        # Single query: fetch all lessons, prioritising today's pool. The DB
        # will materialise more rows than we need on dense days, but the
        # ORDER BY keeps day-specific rows first so the slice is correct.
        stmt = (
            select(DatelessLesson)
            .order_by(
                (DatelessLesson.display_day_of_year != doy).asc(),
                DatelessLesson.slug.asc(),
            )
            .limit(limit * 8)  # generous overshoot, then shuffle in Python
        )
        result = await self.session.exec(stmt)
        rows = [row[0] for row in result.all()]

        day_pool = [r for r in rows if r.display_day_of_year == doy]
        backfill_pool = [r for r in rows if r.display_day_of_year != doy]

        random.Random(f"{year}:{doy}").shuffle(day_pool)
        random.Random(f"{year}:{doy}:global").shuffle(backfill_pool)

        return (day_pool + backfill_pool)[:limit]

    async def _pick_observance(self, hijri_day: int, hijri_month: int) -> Observance | None:
        """Look up the observance, if any, anchored to today's Hijri date."""
        stmt = (
            select(Observance)
            .where(
                Observance.hijri_month == hijri_month,
                Observance.hijri_day == hijri_day,
            )
            .limit(1)
        )
        result = await self.session.exec(stmt)
        row = result.first()
        return row[0] if row is not None else None
