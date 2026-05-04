"""Response shape for ``GET /api/v1/today`` and ``GET /api/v1/recent``."""

from iotd.api.schemas.event import EventDetail, EventSummary
from iotd.api.schemas.lesson import LessonDetail, LessonSummary
from iotd.api.schemas.shared import ResponseModel

AnyDetail = EventDetail | LessonDetail
AnySummary = EventSummary | LessonSummary


class GregorianDate(ResponseModel):
    """Calendar slot — Gregorian side."""

    day: int
    month: str
    year: int
    weekday: str


class HijriDate(ResponseModel):
    """Calendar slot — Hijri side."""

    day: int
    month: str
    month_short: str
    year: int
    weekday: str | None = None


class TodayCalendar(ResponseModel):
    """Co-primary calendar pair surfaced in the masthead."""

    gregorian: GregorianDate
    hijri: HijriDate


class ObservanceRef(ResponseModel):
    """Active annual observance, if one is in season."""

    id: str
    name: str
    name_ar: str | None = None
    name_fr: str | None = None
    hijri_date: str
    summary: str | None = None
    summary_ar: str | None = None
    summary_fr: str | None = None


class TodayResponse(ResponseModel):
    """The full ``/api/v1/today`` payload."""

    today: TodayCalendar
    headline: AnyDetail | None = None
    secondary: list[AnySummary] = []
    observance: ObservanceRef | None = None


class RecentDay(ResponseModel):
    """One day inside the ``/api/v1/recent`` response."""

    date: str
    calendar: TodayCalendar
    headline: AnyDetail | None = None
    observance: ObservanceRef | None = None


class RecentResponse(ResponseModel):
    """The full ``/api/v1/recent`` payload."""

    days: list[RecentDay]
