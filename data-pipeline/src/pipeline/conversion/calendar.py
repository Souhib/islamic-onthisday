"""Precision-aware Hijri <-> Gregorian conversion.

Uses the classical tabular algorithm via :mod:`convertdate.islamic`, which
works from 1 AH (622 CE) onward. Always approximate — Hijri dates derived
from modern algorithms can differ from historically observed dates by ±1-3
days. Callers are expected to prefer attested Gregorian dates in curated
content when available, and use this module only as fallback.
"""

from datetime import date

from convertdate import islamic

from pipeline.constants import (
    HIJRI_MONTH_MID_DAY,
    HIJRI_YEAR_MID_DAY,
    HIJRI_YEAR_MID_MONTH,
    MD_KEY_MULTIPLIER,
)
from pipeline.schemas import GregorianDate, HijriDate, Precision


def hijri_to_gregorian(hijri: HijriDate) -> GregorianDate | None:
    """Convert a Hijri date to Gregorian while preserving precision.

    Year- and month-precision inputs are anchored at a mid-month/mid-year
    point so the resulting Gregorian date is within the correct calendar
    span but is explicitly flagged ``precision=year|month`` in the output.

    Args:
        hijri: A Hijri date with its precision set (year/month/day).

    Returns:
        A :class:`GregorianDate` with ``method='tabular_conversion'``, or ``None`` if the input does not carry a Hijri year.
    """
    if hijri.year is None:
        return None

    if hijri.precision == Precision.DAY and hijri.month and hijri.day:
        year, month, day = islamic.to_gregorian(hijri.year, hijri.month, hijri.day)
        return GregorianDate(
            date=date(year, month, day),
            precision=Precision.DAY,
            method="tabular_conversion",
        )

    if hijri.precision == Precision.MONTH and hijri.month:
        year, month, day = islamic.to_gregorian(hijri.year, hijri.month, HIJRI_MONTH_MID_DAY)
        return GregorianDate(
            date=date(year, month, day),
            precision=Precision.MONTH,
            method="tabular_conversion",
        )

    if hijri.precision == Precision.YEAR:
        year, month, day = islamic.to_gregorian(hijri.year, HIJRI_YEAR_MID_MONTH, HIJRI_YEAR_MID_DAY)
        return GregorianDate(
            date=date(year, month, day),
            precision=Precision.YEAR,
            method="tabular_conversion",
        )

    return None


def gregorian_to_hijri(gregorian: date) -> tuple[int, int, int]:
    """Return ``(year, month, day)`` in the Islamic tabular calendar.

    Args:
        gregorian: The Gregorian date to convert.

    Returns:
        A 3-tuple ``(hijri_year, hijri_month, hijri_day)``.
    """
    return islamic.from_gregorian(gregorian.year, gregorian.month, gregorian.day)


def greg_doy(gregorian: date) -> int:
    """Day-of-year in the Gregorian calendar (1-366).

    Args:
        gregorian: Any Gregorian date.

    Returns:
        An integer between 1 and 366 inclusive.
    """
    return gregorian.timetuple().tm_yday


def hijri_md_key(month: int, day: int) -> int:
    """Stable lookup key for a Hijri month+day combination regardless of year.

    Args:
        month: Hijri month (1-12).
        day: Hijri day (1-30).

    Returns:
        An integer key suitable for indexed SQL equality lookups.
    """
    return month * MD_KEY_MULTIPLIER + day
