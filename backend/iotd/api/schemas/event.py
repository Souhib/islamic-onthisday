"""Pydantic response shapes for the Event resource.

**Trilingual policy.** Every event carries ``title``/``title_ar``/``title_fr``
and ``summary``/``summary_ar``/``summary_fr`` (plus body parts). The backend
returns all three; the front-end picks one based on the user's language
preference, falling back to English when a translation is missing. Stateless
and cache-friendly — no ``?lang=`` parameter on the backend.

**Discriminants over labels.** The API exposes machine-readable values
(``verification_status="cross_verified"``, ``dispute_about="date"``,
``weight="primary"``); rendering the human-readable label is the front-end's
job, so the same payload serves all three locales without duplication.
"""

from typing import Literal

from iotd.api.schemas.shared import ResponseModel

# Verification ladder. The pipeline column is a free-form string for
# forward-compat, but the API contract is a closed enum — anything outside
# the union becomes ``"unverified"`` at the projection boundary.
VerificationStatus = Literal[
    "scholar_reviewed",
    "cross_verified",
    "single_source",
    "auto_verified",
    "unverified",
]
DisputeAbout = Literal["date", "detail", "interpretation"]


class PersonRef(ResponseModel):
    """A person attached to an event."""

    id: str
    name: str
    name_ar: str | None = None
    name_fr: str | None = None
    role: str | None = None


class SourceRef(ResponseModel):
    """A citable source attached to an event."""

    label: str
    kind: Literal["classical", "primary", "modern"]
    verify: str | None = None


class DisputedPosition(ResponseModel):
    """One scholarly position on a disputed date or fact.

    ``weight`` is a discriminant (``primary | notable | minority``) — the
    front-end maps it to a localised label.
    """

    rank: int
    value: str
    scholars: str
    weight: Literal["primary", "notable", "minority"]


class EventSummary(ResponseModel):
    """Slim event projection for "On this day" rotation rails — trilingual."""

    id: str  # the event's slug
    title: str
    title_ar: str | None = None
    title_fr: str | None = None
    hijri: str | None = None
    gregorian: str | None = None
    era: str | None = None
    importance: str
    verification_status: VerificationStatus
    disputed: bool = False
    dispute_about: DisputeAbout | None = None


class EventDetail(ResponseModel):
    """Full event projection used by the headline + event-detail surfaces.

    Trilingual: ``title`` (English) + ``title_ar`` (Arabic) + ``title_fr``
    (French) all surfaced; ``summary`` and ``body`` likewise. Front-end
    chooses which to render.
    """

    id: str
    title: str
    title_ar: str | None = None
    title_fr: str | None = None
    era: str | None = None
    importance: str
    verification_status: VerificationStatus
    gregorian: str | None = None
    hijri: str | None = None
    location: str | None = None
    placeholder: str | None = None
    no_image: bool = False
    image_url: str | None = None
    summary: str
    summary_ar: str | None = None
    summary_fr: str | None = None
    body: list[str] = []
    body_ar: list[str] = []
    body_fr: list[str] = []
    people: list[PersonRef] = []
    sources: list[SourceRef] = []
    disputed: bool = False
    # When ``disputed`` is true, what aspect is contested:
    #   "date"           — the canonical date is one of several attested
    #                      positions (the event itself is well-attested).
    #   "detail"         — a small detail of the event is contested.
    #   "interpretation" — a status / qualification is contested.
    # Drives how prominently the front-end surfaces the dispute.
    dispute_about: DisputeAbout | None = None
    disputed_positions: list[DisputedPosition] = []
    source_url: str | None = None
