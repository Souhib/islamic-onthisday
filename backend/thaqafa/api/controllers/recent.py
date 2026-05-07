"""Recent controller — builds the last N days of Today payloads.

Every per-day Today response runs ~4 queries (headline + secondary + lessons
+ observance). Naively looping ``today_controller.today(d)`` 7-14 times means
~28-56 queries for one ``/recent`` request — we instead batch the headline,
lesson-fallback, and observance lookups across all dates.

**Lesson fallback.** Many calendar days have no curated event yet (the
dataset isn't dense — ~3 events/day on average, very uneven). When a day
has no event headline we fall back to a dateless lesson keyed by
day-of-year, mirroring ``TodayController``'s behaviour. Lessons rotate
deterministically per ``(year, doy)`` so the same date always shows the
same lesson — important for "what did I read on Monday?" continuity.
"""

import random
from datetime import UTC, date, datetime, timedelta

from pipeline.models.db import DateClaim, DatelessLesson, Event, EventPerson, Observance
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from thaqafa.api.constants import (
    HEADLINE_IMPORTANCE,
    HEADLINE_VERIFICATION_STATUSES,
    HIJRI_MD_FACTOR,
    RECENT_WINDOW_DAYS,
)
from thaqafa.api.schemas.today import RecentDay, RecentResponse, TodayCalendar
from thaqafa.api.services.calendar import calendar_for, hijri_month_index, project_observance_ref
from thaqafa.api.services.projections import project_event_detail, project_lesson_detail


class RecentController:
    """Picks the headline and observance for the last N calendar days."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def recent(self) -> RecentResponse:
        """Build the Recent payload for the last :data:`RECENT_WINDOW_DAYS` days.

        Returns:
            A ``RecentResponse`` where ``days[0]`` is today and
            ``days[-1]`` is ``RECENT_WINDOW_DAYS - 1`` days ago.
        """
        today = datetime.now(UTC).date()
        dates = [today - timedelta(days=i) for i in range(RECENT_WINDOW_DAYS)]
        return await self._build_days(dates)

    async def upcoming(self, days: int) -> RecentResponse:
        """Build the next ``days`` calendar days, starting today.

        Used by the mobile app to pre-fetch upcoming headlines so it
        can schedule rich-content local notifications without a push
        server. Same shape as ``recent()`` but the dates run forward
        from today instead of backward, and ``days`` is caller-controlled
        (mobile schedules ~7-30 days at a time).
        """
        today = datetime.now(UTC).date()
        dates = [today + timedelta(days=i) for i in range(days)]
        return await self._build_days(dates)

    async def _build_days(self, dates: list[date]) -> RecentResponse:
        """Shared composer for ``recent`` and ``upcoming``."""
        calendars = [calendar_for(d) for d in dates]
        headlines = await self._pick_headlines(dates, calendars)
        missing = [d for d in dates if d not in headlines]
        lesson_fallbacks = await self._pick_lesson_fallbacks(missing) if missing else {}
        observances = await self._pick_observances(calendars)

        recent_days: list[RecentDay] = []
        for d, calendar in zip(dates, calendars, strict=True):
            event = headlines.get(d)
            lesson = lesson_fallbacks.get(d)
            obs = observances.get((calendar.hijri.day, hijri_month_index(calendar.hijri.month)))
            if event is not None:
                headline = project_event_detail(event)
            elif lesson is not None:
                headline = project_lesson_detail(lesson)
            else:
                headline = None
            recent_days.append(
                RecentDay(
                    date=d.isoformat(),
                    calendar=calendar,
                    headline=headline,
                    observance=project_observance_ref(obs) if obs else None,
                )
            )

        return RecentResponse(days=recent_days)

    async def _pick_headlines(self, dates: list[date], calendars: list[TodayCalendar]) -> dict[date, Event]:
        """One query per importance tier covering every date in the window.

        Returns a ``date → Event`` map. The Hijri/Gregorian DOY indexes mean
        SQLite can use them without a sort; the per-day chosen row is the
        first one we see for that date in the importance walk.
        """
        doys = {d: d.timetuple().tm_yday for d in dates}
        md_keys = {
            d: hijri_month_index(c.hijri.month) * HIJRI_MD_FACTOR + c.hijri.day
            for d, c in zip(dates, calendars, strict=True)
        }
        all_doys = list(doys.values())
        all_md_keys = list(md_keys.values())

        result: dict[date, Event] = {}
        for importance in HEADLINE_IMPORTANCE:
            stmt = (
                select(Event)
                .where(
                    Event.display_gregorian_doy.in_(all_doys) | Event.display_hijri_md_key.in_(all_md_keys),
                    Event.importance == importance,
                    Event.verification_status.in_(HEADLINE_VERIFICATION_STATUSES),
                )
                .options(
                    selectinload(Event.claims).selectinload(DateClaim.source),
                    selectinload(Event.people_links).selectinload(EventPerson.person),
                )
                .order_by(Event.verified.desc(), Event.canonical_gregorian_date.desc())
            )
            rows = [row[0] for row in (await self.session.exec(stmt)).all()]
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

    async def _pick_lesson_fallbacks(self, missing_dates: list[date]) -> dict[date, DatelessLesson]:
        """Find a dateless lesson for each date that has no event headline.

        First tries to match the date's day-of-year. If a date has no
        day-specific lesson either, draws from the global pool with a
        distinct seed so adjacent empty days get different lessons. Mirrors
        the behaviour of ``TodayController._pick_lessons`` so the headline
        a user saw on the original Today page is the same one shown when
        Recent reaches back to that date.
        """
        if not missing_dates:
            return {}
        doys = {d.timetuple().tm_yday for d in missing_dates}
        # One query for every lesson keyed by the doys we need + one global
        # backfill pool. Both come back in a single statement, partitioned
        # client-side — a single roundtrip for the whole window.
        stmt = select(DatelessLesson)
        rows = [row[0] for row in (await self.session.exec(stmt)).all()]
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

    async def _pick_observances(self, calendars: list[TodayCalendar]) -> dict[tuple[int, int], Observance]:
        """Single query for every (hijri_day, hijri_month) the window covers."""
        keys = {(c.hijri.day, hijri_month_index(c.hijri.month)) for c in calendars}
        if not keys:
            return {}
        days = [k[0] for k in keys]
        months = [k[1] for k in keys]
        stmt = select(Observance).where(Observance.hijri_day.in_(days), Observance.hijri_month.in_(months))
        rows = [row[0] for row in (await self.session.exec(stmt)).all()]
        # Build the keyed map so we don't accidentally pair, e.g., (9, 12) with
        # an observance whose hijri_day=9 but hijri_month=11.
        return {(o.hijri_day, o.hijri_month): o for o in rows if o.hijri_day is not None}
