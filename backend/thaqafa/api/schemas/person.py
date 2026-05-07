"""Pydantic response shape for Person."""

from thaqafa.api.schemas.shared import ResponseModel


class PersonDetail(ResponseModel):
    """Full person profile.

    The image policy is enforced upstream by the pipeline: ``image_url`` is
    guaranteed to be ``None`` for any prophet, Sahabi, or member of Ahl
    al-Bayt. The frontend should not rely on its own check, but the value
    is also surfaced explicitly in ``image_blocked_reason`` when applicable.
    """

    id: str  # the slug
    full_name_en: str
    full_name_ar: str | None = None
    kunya: str | None = None
    laqab: str | None = None
    nisba: str | None = None
    role: str | None = None
    biography: str | None = None
    is_prophet: bool = False
    is_sahabi: bool = False
    is_ahl_al_bayt: bool = False
    image_url: str | None = None
    image_blocked_reason: str | None = None
    wikidata_qid: str | None = None
