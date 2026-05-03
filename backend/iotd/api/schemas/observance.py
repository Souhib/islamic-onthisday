"""Response shape for the Observance resource — recurring annual rites."""

from iotd.api.schemas.shared import ResponseModel


class ObservanceDetail(ResponseModel):
    """A recurring Hijri-anchored Islamic observance (Eid, Mawlid, Arafah, …).

    Trilingual: ``name``/``name_ar``/``name_fr`` and
    ``description``/``description_ar``/``description_fr``.
    """

    id: str  # the slug
    name_en: str
    name_ar: str | None = None
    name_fr: str | None = None
    description_en: str
    description_ar: str | None = None
    description_fr: str | None = None
    hijri_month: int  # 1–12
    hijri_day: int | None = None  # None for multi-day windows
    window_days: int = 1
    importance: str  # "major" | "notable" | "minor"
    quran_refs: str | None = None
    hadith_refs: str | None = None
