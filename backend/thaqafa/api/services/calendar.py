"""Calendar helpers — Gregorian / Hijri pairing, observance projection.

These used to live in both ``controllers/today.py`` and ``controllers/recent.py``
verbatim; pulling them into one module removes the drift hazard. They're
pure (no DB, no I/O) so any controller can call them.
"""

from datetime import date

from convertdate import islamic
from pipeline.models.db import Observance

from thaqafa.api.constants import (
    GREGORIAN_MONTH_NAMES,
    HIJRI_MONTH_NAMES_LONG,
    HIJRI_MONTH_NAMES_SHORT,
    WEEKDAY_NAMES,
)
from thaqafa.api.schemas.today import ObservanceRef, TodayCalendar


def calendar_for(today: date) -> TodayCalendar:
    """Build the dual-calendar payload (Gregorian + Hijri) for a date."""
    hijri_year, hijri_month, hijri_day = islamic.from_gregorian(today.year, today.month, today.day)
    return TodayCalendar(
        gregorian={
            "day": today.day,
            "month": GREGORIAN_MONTH_NAMES[today.month - 1],
            "year": today.year,
            "weekday": WEEKDAY_NAMES[today.weekday()],
        },
        hijri={
            "day": hijri_day,
            "month": HIJRI_MONTH_NAMES_LONG[hijri_month - 1],
            "month_short": HIJRI_MONTH_NAMES_SHORT[hijri_month - 1],
            "year": hijri_year,
        },
    )


def project_observance_ref(obs: Observance) -> ObservanceRef:
    """Project an :class:`Observance` row to the slim ``ObservanceRef``."""
    return ObservanceRef(
        id=obs.slug,
        name=obs.name_en,
        name_ar=obs.name_ar,
        name_fr=obs.name_fr,
        hijri_date=f"{obs.hijri_day} {HIJRI_MONTH_NAMES_LONG[obs.hijri_month - 1]}",
        summary=obs.description_en[:240] if obs.description_en else None,
        summary_ar=obs.description_ar[:240] if obs.description_ar else None,
        summary_fr=obs.description_fr[:240] if obs.description_fr else None,
    )


def hijri_month_index(name: str) -> int:
    """Reverse-lookup a Hijri month index (1-12) from its long name.

    Returns ``1`` (Muḥarram) on unknown input — defensive default that
    keeps the picker functional even if a calendar string drifts.
    """
    try:
        return HIJRI_MONTH_NAMES_LONG.index(name) + 1
    except ValueError:
        return 1
