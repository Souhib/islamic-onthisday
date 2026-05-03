"""Generic list-response wrapper used by the browse + search endpoints."""

from iotd.api.schemas.event import EventSummary
from iotd.api.schemas.shared import ResponseModel


class EventListResponse(ResponseModel):
    """Paginated list of events with the matched filter context echoed back."""

    items: list[EventSummary]
    total: int
    limit: int
    offset: int
